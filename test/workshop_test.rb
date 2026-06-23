# frozen_string_literal: true

require_relative "test_helper"
require "tmpdir"

# bin/workshop arranges the workbench. A discovery (scout) session has no slice and no tests,
# so it must omit the watcher / TDD loop. These drive the manual launcher (no GUI, just prints
# the steps) and assert on what it arranges.
class WorkshopTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_discovery_session_omits_the_watcher
    out = run_manual_workshop("WORKSHOP_MODE=scout\n")

    refute_includes out, "bin/watch", "a scout discovery session has no test loop, so no watcher"
    assert_includes out, "Discovery", "it should say why there's no watcher"
  end

  def test_slice_session_keeps_the_watcher
    out = run_manual_workshop("WORKSHOP_MODE=navigator\n")

    assert_includes out, "bin/watch", "a normal slice session keeps the TDD watcher"
  end

  def test_explicit_watch_override_wins_over_scout
    out = run_manual_workshop("WORKSHOP_MODE=scout\nWORKSHOP_WATCH=1\n")

    assert_includes out, "bin/watch", "an explicit WORKSHOP_WATCH=1 forces the watcher even in scout"
  end

  private

  def run_manual_workshop(workshoprc)
    Dir.mktmpdir("ws") do |dir|
      File.write(File.join(dir, ".workshoprc"), workshoprc)
      out, err, status = Open3.capture3({ "WORKSHOP_LAUNCHER" => "manual" },
                                        File.join(ROOT, "bin", "workshop"), dir)
      assert status.success?, err
      out
    end
  end
end
