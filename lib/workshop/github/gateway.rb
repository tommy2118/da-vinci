# frozen_string_literal: true

module Workshop
  module Github
    # The domain seam for the github-project shape. Speaks issues, epics, and board status;
    # asks Cli for the raw gh data. Refuses to know how gh formats JSON or how MISSION.md /
    # ANATOMY.md are structured (that is bin/issue's job).
    class Gateway
      def initialize(repo:, project: nil, owner: nil, cli: nil)
        @repo = repo
        @project = project
        @owner = owner || repo.split("/").first
        @cli = cli || Cli.new(repo: repo)
      end

      def issue(number)
        Issue.from_json(@cli.issue(number))
      end

      def tasks
        @cli.issue_list(labels: ["type:task"]).map { |hash| Issue.from_json(hash) }
      end

      # Best-effort: task issues whose title or body mention the epic's short-code (e.g. "E5").
      # GitHub sub-issue links aren't used here, so the code reference is the only join.
      def tasks_for(epic_number)
        code = issue(epic_number).epic_code
        return [] unless code

        tasks.select { |task| task.title.include?(code) || task.body.include?(code) }
      end

      # Move the issue's card to a named board column (e.g. "In Progress"). Outgoing command.
      def set_status(issue_number, status_name)
        require_project!
        apply_status(item_for(issue_number).fetch("id"), status_name)
      end

      # Create an issue. Returns { number:, url: }. Does not touch the board (see add_to_board).
      def create_issue(title:, body: nil, labels: [])
        url = @cli.create_issue(title: title, body: body, labels: labels)
        { number: Integer(url[%r{/issues/(\d+)}, 1]), url: url }
      end

      # Add an already-created issue (by url) to the board, optionally in a named column.
      def add_to_board(url, status: nil)
        require_project!
        item = @cli.add_project_item(@project, @owner, url)
        apply_status(item.fetch("id"), status) if status
        item
      end

      # Open a PR that closes the issue. Returns the PR url printed by gh.
      def open_pr(issue_number, base:, head:, title: nil, body: nil)
        @cli.create_pr(
          base: base, head: head,
          title: title || issue(issue_number).title,
          body: [body, "Closes ##{Integer(issue_number)}"].compact.join("\n\n")
        )
      end

      private

      def require_project!
        raise Error, "no project configured — set WORKSHOP_GH_PROJECT or pass --project" unless @project
      end

      def apply_status(item_id, status_name)
        field = status_field
        option = option_named(field, status_name)
        @cli.edit_item(project_id: project_id, item_id: item_id, field_id: field.fetch("id"), option_id: option.fetch("id"))
      end

      def project_id
        @project_id ||= @cli.project_view(@project, @owner).fetch("id")
      end

      def item_for(issue_number)
        number = Integer(issue_number)
        item = @cli.project_items(@project, @owner).find { |i| i.dig("content", "number") == number }
        raise Error, "issue ##{number} is not on project #{@project}" unless item

        item
      end

      def status_field
        field = @cli.project_fields(@project, @owner).find { |f| f["name"] == "Status" }
        raise Error, "project #{@project} has no 'Status' single-select field — add one to the board first" unless field

        field
      end

      def option_named(field, status_name)
        option = Array(field["options"]).find { |o| o.fetch("name").casecmp?(status_name) }
        return option if option

        have = Array(field["options"]).map { |o| o.fetch("name") }.join(", ")
        raise Error, "no Status option named #{status_name.inspect} (have: #{have})"
      end
    end
  end
end
