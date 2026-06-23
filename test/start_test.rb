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
                                    "--tracker", "https://app.clickup.com/t/abc123", "--no-launch")

      assert status.success?, err
      assert_includes read(content, "tracked", "MISSION.md"), "abc123"
    end
  end

  def test_normalizes_a_clickup_pointer
    in_content_dir do |content|
      _out, err, status = run_start(content, "cu", "--problem", "x",
                                    "--tracker", "https://app.clickup.com/t/abc123", "--no-launch")

      assert status.success?, err
      mission = read(content, "cu", "MISSION.md")
      assert_includes mission, "ClickUp"
      assert_includes mission, "abc123"
    end
  end

  def test_normalizes_a_linear_pointer
    in_content_dir do |content|
      _out, err, status = run_start(content, "ln", "--problem", "x",
                                    "--tracker", "https://linear.app/acme/issue/ENG-123/add-webhooks", "--no-launch")

      assert status.success?, err
      mission = read(content, "ln", "MISSION.md")
      assert_includes mission, "Linear"
      assert_includes mission, "ENG-123"
    end
  end

  def test_records_an_unrecognized_tracker_as_a_generic_pointer
    in_content_dir do |content|
      _out, err, status = run_start(content, "other", "--problem", "x",
                                    "--tracker", "https://example.test/board/9", "--no-launch")

      assert status.success?, err
      assert_includes read(content, "other", "MISSION.md"), "https://example.test/board/9"
    end
  end

  def test_seeds_discovery_from_a_github_issue
    in_content_dir do |content|
      Dir.mktmpdir("fakebin") do |fakebin|
        write_fake_gh(fakebin)

        _out, err, status = run_start(content, "webhooks",
                                      "--problem", "Emit webhooks",
                                      "--issue", "https://github.com/acme/store/issues/77",
                                      "--no-launch", extra_path: fakebin)

        assert status.success?, err
        mission = read(content, "webhooks", "MISSION.md")
        assert_includes mission, "Webhooks on order events", "issue title should seed the brief"
        assert_includes mission, "webhook fires", "issue body should seed the brief"
      end
    end
  end

  def test_falls_back_to_a_pointer_when_the_issue_fetch_fails
    in_content_dir do |content|
      Dir.mktmpdir("fakebin") do |fakebin|
        write_failing_gh(fakebin)

        _out, err, status = run_start(content, "degraded",
                                      "--problem", "X",
                                      "--issue", "https://github.com/acme/store/issues/77",
                                      "--no-launch", extra_path: fakebin)

        assert status.success?, "a failed fetch must degrade gracefully, not abort: #{err}"
        assert_includes read(content, "degraded", "MISSION.md"), "issues/77", "pointer is still recorded"
      end
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

  def run_start(content_dir, *args, extra_path: nil)
    env = { "WORKSHOP_CONTENT_DIR" => content_dir }
    env["PATH"] = "#{extra_path}:#{ENV['PATH']}" if extra_path
    Open3.capture3(env, File.join(ROOT, "bin", "start"), *args)
  end

  # A gh stand-in on PATH so bin/issue (and the real Workshop::Github::Cli) run end to end
  # without the network. The real authenticated gh is on PATH, so tests must always shadow it.
  def write_fake_gh(dir)
    json = '{"number":77,"title":"Webhooks on order events",' \
           '"body":"Given an order is placed\nThen a webhook fires",' \
           '"labels":[],"url":"https://github.com/acme/store/issues/77","state":"OPEN"}'
    write_gh(dir, "if [ \"$1\" = \"issue\" ] && [ \"$2\" = \"view\" ]; then\n" \
                  "  printf '%s' '#{json}'\n  exit 0\nfi\nexit 1\n")
  end

  def write_failing_gh(dir)
    write_gh(dir, "exit 1\n")
  end

  def write_gh(dir, body)
    path = File.join(dir, "gh")
    File.write(path, "#!/usr/bin/env bash\n#{body}")
    File.chmod(0o755, path)
  end

  def read(*parts)
    File.read(File.join(*parts))
  end
end
