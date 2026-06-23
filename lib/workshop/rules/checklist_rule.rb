# frozen_string_literal: true

module Workshop
  module Rules
    class ChecklistRule
      EXPECTED_ITEMS = [
        "One-screen test",
        "One-sentence test",
        "Refusal-list completeness",
        "Joint completeness",
        "Walk test",
        "Red-shape test",
        "Bypass-audit honesty",
        "Timer test"
      ].freeze

      def call(slice)
        unchecked = EXPECTED_ITEMS.reject do |item|
          slice.anatomy.match?(/^- \[x\] #{Regexp.escape(item)}/)
        end

        if unchecked.empty?
          CheckResult.new(true, "verification checklist is complete")
        else
          CheckResult.new(false, "unchecked checklist items: #{unchecked.join(', ')}")
        end
      end
    end
  end
end
