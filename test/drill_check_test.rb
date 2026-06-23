# frozen_string_literal: true

require_relative "test_helper"
require "tmpdir"
require "fileutils"

class DrillCheckTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_rules_pass_for_complete_slice
    results = check("complete_slice")

    assert results.all?(&:ok?), failure_messages(results)
  end

  def test_refusal_lists_rule_flags_objects_with_too_few_refusals
    rule = Workshop::Rules::RefusalListsRule.new
    slice = Workshop::Slice.new(File.join(ROOT, "test", "fixtures", "incomplete_slice"))

    result = rule.call(slice)

    refute result.ok?
    assert_includes result.message, "Service"
  end

  def test_slice_detects_external_target_from_workshoprc
    assert fixture_slice("external_target_slice").external_target?
    refute fixture_slice("complete_slice").external_target?
  end

  def test_acceptance_spec_rule_accepts_external_target_pointer
    rule = Workshop::Rules::AcceptanceSpecRule.new

    result = rule.call(fixture_slice("external_target_slice"))

    assert result.ok?, result.message
    assert_includes result.message, "external-target pointer"
  end

  def test_external_target_slice_passes_full_drill_check
    results = check("external_target_slice")

    assert results.all?(&:ok?), failure_messages(results)
  end

  # The gate never runs the spec, so its only defense against a green-but-meaningless
  # acceptance test is to confirm a live, enabled assertion exists. These pin the holes
  # found while stress-testing: an assertion present only in a comment, and a disabled
  # example (xit/skip/pending) whose green run proves nothing.

  def test_acceptance_spec_rule_rejects_expect_only_in_a_comment
    rule = Workshop::Rules::AcceptanceSpecRule.new
    slice = slice_with_spec(<<~SPEC)
      RSpec.describe "x" do
        it "does nothing" do
          # expect(thing).to eq("real")  <- commented out, never executed
          1 + 1
        end
      end
    SPEC

    result = rule.call(slice)

    refute result.ok?, "a commented-out assertion should not satisfy the gate"
    assert_includes result.message, "missing assertions"
  end

  def test_acceptance_spec_rule_rejects_skipped_example
    rule = Workshop::Rules::AcceptanceSpecRule.new
    slice = slice_with_spec(<<~SPEC)
      RSpec.describe "x" do
        xit "skipped entirely" do
          expect(real_thing).to eq("never runs")
        end
      end
    SPEC

    result = rule.call(slice)

    refute result.ok?, "an xit-disabled example should not satisfy the gate"
    assert_includes result.message, "disabled"
  end

  def test_acceptance_spec_rule_rejects_skip_before_the_only_assertion
    rule = Workshop::Rules::AcceptanceSpecRule.new
    slice = slice_with_spec(<<~SPEC)
      RSpec.describe "x" do
        it "bails out" do
          skip "not ready"
          expect(real_thing).to eq("never reached")
        end
      end
    SPEC

    result = rule.call(slice)

    refute result.ok?, "a skip before the assertion should not satisfy the gate"
    assert_includes result.message, "disabled"
  end

  def test_acceptance_spec_rule_accepts_a_live_enabled_assertion
    rule = Workshop::Rules::AcceptanceSpecRule.new
    slice = slice_with_spec(<<~SPEC)
      RSpec.describe "x" do
        it "walks the happy path" do
          expect(result).to eq("applied")
        end
      end
    SPEC

    result = rule.call(slice)

    assert result.ok?, result.message
  end

  private

  def slice_with_spec(spec)
    dir = Dir.mktmpdir("drill-slice")
    FileUtils.mkdir_p(File.join(dir, "spec"))
    File.write(File.join(dir, "spec", "acceptance_spec.rb"), spec)
    Workshop::Slice.new(dir)
  end

  def check(fixture_name)
    Workshop::DrillCheck.new.call(fixture_slice(fixture_name))
  end

  def fixture_slice(fixture_name)
    Workshop::Slice.new(File.join(ROOT, "test", "fixtures", fixture_name))
  end

  def failure_messages(results)
    results.reject(&:ok?).map(&:message).join(", ")
  end
end
