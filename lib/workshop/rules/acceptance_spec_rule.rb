# frozen_string_literal: true

module Workshop
  module Rules
    class AcceptanceSpecRule
      PLACEHOLDERS = [
        "pending ",
        "raise \"remove this when the test asserts something real\"",
        "TODO: pin the happy-path walk"
      ].freeze

      def call(slice)
        spec = slice.acceptance_spec

        placeholder = PLACEHOLDERS.find { |marker| spec.include?(marker) }
        return CheckResult.new(false, "acceptance spec still contains placeholder text") if placeholder

        if slice.external_target?
          return CheckResult.new(true, "acceptance spec is an external-target pointer → #{slice.target_repo}")
        end

        return CheckResult.new(false, "acceptance spec is missing assertions") unless spec.include?("expect(")

        CheckResult.new(true, "acceptance spec asserts real behavior")
      end
    end
  end
end
