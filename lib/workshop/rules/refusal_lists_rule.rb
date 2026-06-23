# frozen_string_literal: true

module Workshop
  module Rules
    class RefusalListsRule
      def call(slice)
        sections = refusal_sections(slice.anatomy)
        weak_sections = sections.select { |title, bullets| title.nil? || bullets.size < 2 }

        if sections.empty?
          CheckResult.new(false, "no refusal-list objects found")
        elsif weak_sections.empty?
          CheckResult.new(true, "refusal lists cover each object")
        else
          names = weak_sections.map { |title, _| title || "(unnamed object)" }
          CheckResult.new(false, "refusal lists need 2+ bullets for: #{names.join(', ')}")
        end
      end

      private

      def refusal_sections(anatomy)
        in_section = false
        current_title = nil
        sections = []

        anatomy.each_line do |line|
          stripped = line.strip
          in_section = true if stripped.start_with?("## Refusals")
          break if in_section && stripped.start_with?("## Walk-through")
          next unless in_section

          if stripped.start_with?("### ")
            current_title = stripped.delete_prefix("### ")
            sections << [current_title, []]
          elsif stripped.start_with?("- ") && sections.any?
            sections.last[1] << stripped
          end
        end

        sections
      end
    end
  end
end
