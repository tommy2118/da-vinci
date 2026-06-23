# frozen_string_literal: true

require "date"

module Workshop
  # Builds a new note's slug + content. A pure function of (attributes + injected mission +
  # injected clock + template): no filesystem, no validation of the world — the caller writes
  # the file and Note validates it on load. Defaults resolve by precedence:
  # explicit attribute -> active mission -> hard fallback.
  class NoteScaffold
    DEFAULT_STATUS_BY_TYPE = {
      "decision" => "accepted",
      "question" => "open",
      "finding" => "open",
      "gotcha" => "open",
      "reference" => "n/a",
      "lesson" => "n/a"
    }.freeze

    def initialize(template:, clock: Date, mission: nil)
      @template = template
      @clock = clock
      @mission = mission
    end

    def build(attributes, existing_slugs: [])
      note = resolve(attributes)
      slug = unique_slug(note[:title], note[:mission], existing_slugs)
      { slug: slug, content: frontmatter(note) + "\n" + body(note) }
    end

    private

    attr_reader :template, :clock, :mission

    def resolve(attrs)
      type = attrs[:type] || "finding"
      {
        title: attrs.fetch(:title),
        type: type,
        realm: attrs[:realm] || mission&.realm || "personal",
        mission: attrs[:mission] || mission&.name || "workshop",
        target: attrs.key?(:target) ? attrs[:target] : mission&.target,
        slice: attrs[:slice],
        status: attrs[:status] || DEFAULT_STATUS_BY_TYPE.fetch(type, "open"),
        tags: attrs[:tags] || [],
        created: clock.today.iso8601
      }
    end

    def frontmatter(note)
      lines = ["---"]
      lines << %(title: "#{escape(note[:title])}")
      lines << "type: #{note[:type]}"
      lines << "realm: #{note[:realm]}"
      lines << "mission: #{note[:mission]}"
      lines << "target: #{note[:target]}" if present?(note[:target])
      lines << %(slice: "#{note[:slice]}") if present?(note[:slice])
      lines << %(status: "#{note[:status]}")
      lines << "tags: [#{note[:tags].join(', ')}]" unless note[:tags].empty?
      lines << %(created: "#{note[:created]}")
      lines << "---"
      "#{lines.join("\n")}\n"
    end

    def body(note)
      text = template.gsub("{{TITLE}}", note[:title]).gsub("{{META}}", meta(note))
      text = with_decision_section(text) if note[:type] == "decision"
      text
    end

    def meta(note)
      scope = present?(note[:slice]) ? "#{note[:mission]}/#{note[:slice]}" : note[:mission]
      parts = [note[:type], note[:realm], scope]
      parts << "target:#{note[:target]}" if present?(note[:target])
      parts << note[:created]
      parts.join(" · ")
    end

    def with_decision_section(text)
      text.sub("## See also", "## Decision / alternatives\n\n## See also")
    end

    def unique_slug(title, mission, taken)
      base = mission == "workshop" ? slugify(title) : "#{mission}-#{slugify(title)}"
      return base unless taken.include?(base)

      (2..).each { |n| return "#{base}-#{n}" unless taken.include?("#{base}-#{n}") }
    end

    def slugify(title)
      title.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-+|-+\z/, "")
    end

    def escape(text)
      text.gsub('"', '\"')
    end

    def present?(value)
      !value.nil? && !value.to_s.strip.empty?
    end
  end
end
