# frozen_string_literal: true

module Workshop
  module Rules
    class RequiredSectionsRule
      REQUIRED_SECTIONS = [
        "## Collaborators",
        "## Joints",
        "## Refusals",
        "## Walk-through",
        "## Bypass risks",
        "## Verification checklist"
      ].freeze

      def call(slice)
        missing = REQUIRED_SECTIONS.reject { |section| slice.anatomy.include?(section) }

        if missing.empty?
          CheckResult.new(true, "required anatomy sections present")
        else
          CheckResult.new(false, "missing sections: #{missing.join(', ')}")
        end
      end
    end
  end
end
