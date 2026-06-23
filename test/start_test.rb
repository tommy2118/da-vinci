# frozen_string_literal: true

require_relative "test_helper"
require "tmpdir"
require "fileutils"

# Acceptance test for the step-zero entry command, bin/start. It turns a problem-shaped
# thing into a discovery-ready mission and (unless --no-launch) hands off to bin/workshop
# in scout mode. These shell out to the real CLI, like drill_check_integration_test.
class StartTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_scaffolds_a_discovery_mission_for_a_kata
    in_content_dir do |content|
      out, err, status = run_start(content, "voucher-claims",
                                   "--problem", "Redeem vouchers at checkout", "--no-launch")

      assert status.success?, err
      mission = read(content, "voucher-claims", "MISSION.md")
      assert_includes mission, "Redeem vouchers at checkout"
      assert_includes mission, "Station 0"

      workshoprc = read(content, "voucher-claims", ".workshoprc")
      assert_includes workshoprc, "WORKSHOP_MODE=scout"
      refute_includes workshoprc, "WORKSHOP_TARGET_REPO", "a kata has no target repo"

      assert_includes out, "scout"
    end
  end

  def test_existing_repo_makes_it_an_external_target_mission
    in_content_dir do |content|
      repo = File.join(content, "some-app")
      FileUtils.mkdir_p(repo)

      _out, err, status = run_start(content, "api-thing",
                                    "--problem", "Add an endpoint", "--repo", repo, "--no-launch")

      assert status.success?, err
      assert_includes read(content, "api-thing", "MISSION.md"), repo
      assert_includes read(content, "api-thing", ".workshoprc"), "WORKSHOP_TARGET_REPO=\"#{repo}\""
    end
  end

  def test_records_a_tracker_pointer
    in_content_dir do |content|
      _out, err, status = run_start(content, "tracked",
                                    "--problem", "Fix the thing",
                                    "--issue", "https://github.com/acme/widgets/issues/42", "--no-launch")

      assert status.success?, err
      assert_includes read(content, "tracked", "MISSION.md"), "issues/42"
    end
  end

  def test_refuses_to_clobber_an_existing_mission
    in_content_dir do |content|
      FileUtils.mkdir_p(File.join(content, "dup"))

      _out, _err, status = run_start(content, "dup", "--problem", "x", "--no-launch")

      refute status.success?, "expected bin/start to refuse to overwrite an existing mission dir"
    end
  end

  def test_requires_a_mission_name
    in_content_dir do |content|
      _out, _err, status = run_start(content, "--problem", "x", "--no-launch")

      refute status.success?, "expected bin/start to require a mission name"
    end
  end

  private

  def in_content_dir
    Dir.mktmpdir("start-content") { |dir| yield dir }
  end

  def run_start(content_dir, *args)
    Open3.capture3({ "WORKSHOP_CONTENT_DIR" => content_dir }, File.join(ROOT, "bin", "start"), *args)
  end

  def read(*parts)
    File.read(File.join(*parts))
  end
end
