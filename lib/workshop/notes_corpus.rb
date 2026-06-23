# frozen_string_literal: true

module Workshop
  # The notes/ directory as a queryable collection. Enumerates Notes, and composes structured
  # filtering (where) with free-text search so the CLI can combine them without a query engine.
  class NotesCorpus
    INDEX_FILE = "INDEX.md"

    def initialize(dir)
      @dir = File.expand_path(dir)
    end

    attr_reader :dir

    def notes
      Dir.glob(File.join(dir, "*.md"))
        .reject { |path| File.basename(path) == INDEX_FILE }
        .sort
        .map { |path| Note.new(path) }
    end

    def where(type: nil, realm: nil, mission: nil, target: nil, tag: nil, status: nil, notes: self.notes)
      notes.select do |note|
        matches?(note.type, type) &&
          matches?(note.realm, realm) &&
          matches?(note.mission, mission) &&
          matches?(note.target, target) &&
          matches?(note.status, status) &&
          (tag.nil? || note.tags.include?(tag))
      end
    end

    def search(query, notes: self.notes)
      return notes if query.nil? || query.strip.empty?

      needle = query.downcase
      notes.select { |note| "#{note.title}\n#{note.body}".downcase.include?(needle) }
    end

    private

    def matches?(value, filter)
      filter.nil? || value == filter
    end
  end
end
