# frozen_string_literal: true

module Workshop
  module Rules
    class AcceptanceSpecRule
      PLACEHOLDERS = [
        "raise \"remove this when the test asserts something real\"",
        "TODO: pin the happy-path walk"
      ].freeze

      # RSpec's x-prefixed groups/examples and a leading skip/pending disable the example,
      # so a green run proves nothing. Anchored to line start so the keyword in a comment
      # or trailing text doesn't count as disabling.
      DISABLED = /\A\s*(?:x(?:it|describe|context|specify|feature)\b|skip\b|pending\b)/

      def call(slice)
        spec = slice.acceptance_spec

        placeholder = PLACEHOLDERS.find { |marker| spec.include?(marker) }
        return CheckResult.new(false, "acceptance spec still contains placeholder text") if placeholder

        if disabled?(spec)
          return CheckResult.new(false, "acceptance spec is disabled (xit/skip/pending) — it proves nothing green")
        end

        if slice.external_target?
          return CheckResult.new(true, "acceptance spec is an external-target pointer → #{slice.target_repo}")
        end

        return CheckResult.new(false, "acceptance spec is missing assertions") unless live_expectation?(spec)

        CheckResult.new(true, "acceptance spec asserts real behavior")
      end

      private

      def disabled?(spec)
        spec.each_line.any? { |line| line.match?(DISABLED) }
      end

      # A live assertion is an expect( on a line that isn't commented out. Strip a trailing
      # comment (but not a "#{" interpolation) so a commented-out expect doesn't count.
      def live_expectation?(spec)
        spec.each_line.any? { |line| line.sub(/#(?!\{).*/, "").include?("expect(") }
      end
    end
  end
end
