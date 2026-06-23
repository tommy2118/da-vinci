# frozen_string_literal: true

require_relative "test_helper"

class DrillCheckIntegrationTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_cli_reports_success_for_complete_drill
    stdout, stderr, status = run_cli("complete_slice")

    assert status.success?, stderr
    assert_includes stdout, "PASS: required files present"
    assert_includes stdout, "PASS: acceptance spec asserts real behavior"
  end

  def test_cli_reports_failures_for_incomplete_drill
    stdout, stderr, status = run_cli("incomplete_slice")

    refute status.success?, "expected failure, got success: #{stdout}\n#{stderr}"
    assert_includes stdout, "FAIL: unchecked checklist items"
    assert_includes stdout, "FAIL: bypass audit needs 3+ named risks"
    assert_includes stdout, "FAIL: acceptance spec still contains placeholder text"
  end

  private

  def run_cli(fixture_name)
    fixture = File.join(ROOT, "test", "fixtures", fixture_name)
    Open3.capture3(File.join(ROOT, "bin", "drill-check"), fixture)
  end
end
