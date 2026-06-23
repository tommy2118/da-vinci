# frozen_string_literal: true

require_relative "test_helper"

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

  private

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
