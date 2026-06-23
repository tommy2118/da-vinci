# frozen_string_literal: true

require_relative "test_helper"
require_relative "fakes/fake_gh_cli"

class GithubGatewayTest < Minitest::Test
  # --- Workshop::Github::Issue: normalize one issue's json (incoming query) ---

  def test_issue_parses_labels_and_phase_priority
    cli = FakeGhCli.new(issues: { 5 => epic_json(5, "E5 Correlation view", %w[type:epic priority:must phase:prove]) })
    issue = gateway(cli).issue(5)

    assert_equal 5, issue.number
    assert_equal "epic", issue.kind
    assert_equal "must", issue.priority
    assert_equal "prove", issue.phase
    assert_equal "E5", issue.epic_code
  end

  # --- tasks_for: join tasks to an epic by its short-code (incoming query) ---

  def test_tasks_for_selects_tasks_mentioning_the_epic_code
    cli = FakeGhCli.new(issues: {
      5 => epic_json(5, "E5 Correlation view", %w[type:epic]),
      12 => epic_json(12, "PROVE: First failing acceptance test (E5 correlation)", %w[type:task]),
      20 => epic_json(20, "E4 Pressure ingestion adapter", %w[type:task])
    })

    numbers = gateway(cli).tasks_for(5).map(&:number)

    assert_equal [12], numbers
  end

  def test_tasks_for_returns_empty_when_epic_has_no_code
    cli = FakeGhCli.new(issues: { 5 => epic_json(5, "Correlation view", %w[type:epic]) })

    assert_empty gateway(cli).tasks_for(5)
  end

  # --- set_status: resolve item/field/option, then issue the edit (outgoing command) ---

  def test_set_status_edits_the_right_item_field_and_option
    cli = board_cli
    gateway(cli, project: 4).set_status(12, "In Progress")

    assert_equal 1, cli.edits.size
    edit = cli.edits.first
    assert_equal "PVT_x", edit[:project_id]
    assert_equal "ITEM_12", edit[:item_id]
    assert_equal "FLD_status", edit[:field_id]
    assert_equal "OPT_inprogress", edit[:option_id]
  end

  def test_set_status_matches_option_case_insensitively
    cli = board_cli
    gateway(cli, project: 4).set_status(12, "in progress")

    assert_equal "OPT_inprogress", cli.edits.first[:option_id]
  end

  def test_set_status_without_project_raises
    error = assert_raises(Workshop::Github::Error) { gateway(board_cli).set_status(12, "Done") }

    assert_match(/WORKSHOP_GH_PROJECT/, error.message)
  end

  def test_set_status_without_status_field_raises_helpful_hint
    cli = FakeGhCli.new(project: { "id" => "PVT_x" }, items: [item(12)], fields: [])
    error = assert_raises(Workshop::Github::Error) { gateway(cli, project: 4).set_status(12, "Done") }

    assert_match(/no 'Status' single-select field/, error.message)
  end

  def test_set_status_with_unknown_option_lists_the_valid_ones
    cli = board_cli
    error = assert_raises(Workshop::Github::Error) { gateway(cli, project: 4).set_status(12, "Shipping") }

    assert_match(/no Status option named "Shipping"/, error.message)
    assert_match(/In Progress/, error.message)
  end

  def test_set_status_when_issue_not_on_board_raises
    cli = FakeGhCli.new(project: { "id" => "PVT_x" }, items: [item(99)], fields: [status_field])
    error = assert_raises(Workshop::Github::Error) { gateway(cli, project: 4).set_status(12, "Done") }

    assert_match(/issue #12 is not on project 4/, error.message)
  end

  # --- open_pr: appends the closing reference, defaults the title (outgoing command) ---

  def test_open_pr_appends_closes_reference_and_defaults_title
    cli = FakeGhCli.new(issues: { 12 => epic_json(12, "E5 correlation view", %w[type:task]) })
    url = gateway(cli).open_pr(12, base: "master", head: "prove/e5")

    assert_equal "https://github.com/example/repo/pull/1", url
    pr = cli.prs.first
    assert_equal "E5 correlation view", pr[:title]
    assert_match(/Closes #12\z/, pr[:body])
  end

  def test_open_pr_keeps_explicit_title_and_body
    cli = FakeGhCli.new(issues: { 12 => epic_json(12, "x", %w[type:task]) })
    gateway(cli).open_pr(12, base: "master", head: "prove/e5", title: "Custom", body: "Why this PR")

    pr = cli.prs.first
    assert_equal "Custom", pr[:title]
    assert_equal "Why this PR\n\nCloses #12", pr[:body]
  end

  # --- create_issue + add_to_board: the produce-task creation path (outgoing commands) ---

  def test_create_issue_returns_number_from_url_and_records_labels
    cli = FakeGhCli.new(new_issue_url: "https://github.com/o/r/issues/57")
    result = gateway(cli).create_issue(title: "E5 skeleton", body: "why", labels: %w[type:task phase:produce])

    assert_equal 57, result[:number]
    assert_equal "https://github.com/o/r/issues/57", result[:url]
    assert_equal [{ title: "E5 skeleton", body: "why", labels: %w[type:task phase:produce] }], cli.created
  end

  def test_create_issue_does_not_touch_the_board
    cli = FakeGhCli.new
    gateway(cli).create_issue(title: "x")

    assert_empty cli.added
    assert_empty cli.edits
  end

  def test_add_to_board_adds_the_item_and_sets_its_status
    cli = FakeGhCli.new(project: { "id" => "PVT_x" }, fields: [status_field], new_item: { "id" => "ITEM_57" })
    gateway(cli, project: 4).add_to_board("https://github.com/o/r/issues/57", status: "Todo")

    assert_equal ["https://github.com/o/r/issues/57"], cli.added
    assert_equal "ITEM_57", cli.edits.first[:item_id]
    assert_equal "OPT_todo", cli.edits.first[:option_id]
  end

  def test_add_to_board_without_status_only_adds
    cli = FakeGhCli.new(project: { "id" => "PVT_x" }, fields: [status_field])
    gateway(cli, project: 4).add_to_board("https://github.com/o/r/issues/57")

    assert_equal 1, cli.added.size
    assert_empty cli.edits
  end

  private

  def gateway(cli, project: nil)
    Workshop::Github::Gateway.new(repo: "acme/widgets", project: project, cli: cli)
  end

  def board_cli
    FakeGhCli.new(project: { "id" => "PVT_x" }, items: [item(12)], fields: [status_field])
  end

  def status_field
    {
      "id" => "FLD_status", "name" => "Status",
      "options" => [
        { "id" => "OPT_todo", "name" => "Todo" },
        { "id" => "OPT_inprogress", "name" => "In Progress" },
        { "id" => "OPT_done", "name" => "Done" }
      ]
    }
  end

  def item(number)
    { "id" => "ITEM_#{number}", "content" => { "type" => "Issue", "number" => number } }
  end

  def epic_json(number, title, labels)
    { "number" => number, "title" => title, "body" => "", "url" => "u", "state" => "OPEN",
      "labels" => labels.map { |name| { "name" => name } } }
  end
end
