# frozen_string_literal: true

module Workshop
  class DrillCheck
    DEFAULT_RULES = [
      Rules::RequiredFilesRule.new,
      Rules::RequiredSectionsRule.new,
      Rules::ChecklistRule.new,
      Rules::RefusalListsRule.new,
      Rules::BypassAuditRule.new,
      Rules::AcceptanceSpecRule.new
    ].freeze

    def initialize(rules: DEFAULT_RULES)
      @rules = rules
    end

    def call(slice)
      @rules.map { |rule| rule.call(slice) }
    end
  end
end
