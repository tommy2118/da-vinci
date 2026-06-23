# frozen_string_literal: true

require "yaml"

module Workshop
  # One engineering note: a markdown file with a YAML frontmatter head and a prose body.
  # Parses and validates on construction; everything downstream trusts a Note is well-formed.
  class Note
    class InvalidNote < StandardError; end

    TYPES = %w[decision finding gotcha reference question lesson].freeze
    REALMS = %w[professional personal].freeze
    STATUSES = %w[open accepted resolved superseded n/a].freeze

    FRONTMATTER = /\A---\n(?<yaml>.*?)\n---\n(?<body>.*)\z/m

    def initialize(path)
      @path = File.expand_path(path)
      @frontmatter, @body = parse(File.read(@path))
      validate!
    end

    attr_reader :path, :body

    # Slug is the filename, never the title — so renaming a title never breaks a [[wikilink]].
    def slug
      File.basename(path, ".md")
    end

    def title = frontmatter["title"]
    def type = frontmatter["type"]
    def realm = frontmatter["realm"]
    def mission = frontmatter["mission"]
    def target = frontmatter["target"]
    def slice = frontmatter["slice"]
    def status = frontmatter["status"]
    def created = frontmatter["created"]
    def tags = Array(frontmatter["tags"])
    def links = Array(frontmatter["links"])

    private

    attr_reader :frontmatter

    def parse(text)
      match = FRONTMATTER.match(text) or
        raise InvalidNote, "#{slug}: missing YAML frontmatter (file must start with ---)"
      data = YAML.safe_load(match[:yaml])
      raise InvalidNote, "#{slug}: frontmatter is not a mapping" unless data.is_a?(Hash)

      [data, match[:body]]
    end

    def validate!
      raise InvalidNote, "#{slug}: missing title" if blank?(title)
      raise InvalidNote, "#{slug}: missing mission" if blank?(mission)
      reject_unless("type", type, TYPES)
      reject_unless("realm", realm, REALMS)
      reject_unless("status", status, STATUSES)
    end

    def reject_unless(field, value, allowed)
      return if allowed.include?(value)

      raise InvalidNote, "#{slug}: invalid #{field} #{value.inspect} (one of: #{allowed.join(', ')})"
    end

    def blank?(value)
      value.nil? || value.to_s.strip.empty?
    end
  end
end
