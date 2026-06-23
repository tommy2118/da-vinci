# frozen_string_literal: true

module Workshop
  module Rules
    class BypassAuditRule
      MINIMUM_RISKS = 3

      def call(slice)
        risks = risk_rows(slice.anatomy)

        if risks.size >= MINIMUM_RISKS
          CheckResult.new(true, "bypass audit names #{risks.size} risks")
        else
          CheckResult.new(false, "bypass audit needs #{MINIMUM_RISKS}+ named risks")
        end
      end

      private

      def risk_rows(anatomy)
        in_section = false
        rows = []

        anatomy.each_line do |line|
          stripped = line.strip
          in_section = true if stripped.start_with?("## Bypass risks")
          next unless in_section
          break if stripped.start_with?("## Verification checklist")
          next unless stripped.start_with?("|")
          next if stripped.include?("Risk | Likelihood | Mitigation")
          next if stripped.match?(/\|\-+/)

          rows << stripped
        end

        rows
      end
    end
  end
end
