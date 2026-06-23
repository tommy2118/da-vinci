# frozen_string_literal: true

require "open3"
require "json"

module Workshop
  module Github
    # The ONLY object that shells out to `gh`. It knows gh subcommands and JSON, and refuses
    # to know what an epic, a slice, or a board status means — that is Gateway's job.
    # `runner` is injected so the shell-out seam is visible and the wrapper stays testable.
    class Cli
      def initialize(repo:, runner: method(:capture))
        @repo = repo
        @runner = runner
      end

      def issue(number)
        json("issue", "view", number.to_s, "--repo", @repo,
             "--json", "number,title,body,labels,url,state")
      end

      def issue_list(labels: [], state: "open", limit: 100)
        args = ["issue", "list", "--repo", @repo, "--state", state, "--limit", limit.to_s,
                "--json", "number,title,body,labels,url,state"]
        labels.each { |label| args.push("--label", label) }
        json(*args)
      end

      def project_view(number, owner)
        json("project", "view", number.to_s, "--owner", owner, "--format", "json")
      end

      def project_items(number, owner, limit: 200)
        json("project", "item-list", number.to_s, "--owner", owner,
             "--limit", limit.to_s, "--format", "json").fetch("items")
      end

      def project_fields(number, owner)
        json("project", "field-list", number.to_s, "--owner", owner,
             "--format", "json").fetch("fields")
      end

      def edit_item(project_id:, item_id:, field_id:, option_id:)
        run("project", "item-edit", "--id", item_id, "--project-id", project_id,
            "--field-id", field_id, "--single-select-option-id", option_id)
        nil
      end

      def create_pr(title:, body:, base:, head:)
        run("pr", "create", "--repo", @repo, "--base", base, "--head", head,
            "--title", title, "--body", body).strip
      end

      def create_issue(title:, body:, labels:)
        args = ["issue", "create", "--repo", @repo, "--title", title, "--body", body.to_s]
        labels.each { |label| args.push("--label", label) }
        run(*args).strip
      end

      def add_project_item(number, owner, url)
        json("project", "item-add", number.to_s, "--owner", owner, "--url", url, "--format", "json")
      end

      private

      def json(*args)
        JSON.parse(run(*args))
      rescue JSON::ParserError => e
        raise Error, "could not parse gh output: #{e.message}"
      end

      def run(*args)
        out, err, status = @runner.call(["gh", *args])
        raise Error, gh_error(args, err) unless status.success?

        out
      end

      def capture(argv)
        Open3.capture3(*argv)
      end

      def gh_error(args, stderr)
        message = stderr.to_s.strip
        hint = message.match?(/project.*scope|scope.*project/i) ? " (run: gh auth refresh -s project)" : ""
        "gh #{args.first} failed: #{message}#{hint}"
      end
    end
  end
end
