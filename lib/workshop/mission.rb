# frozen_string_literal: true

module Workshop
  # A mission's note-scaffolding context: its name, and the defaults derived from its
  # MISSION.md "Target repo:" line. The only place the filesystem decides realm/target.
  class Mission
    def self.find(missions_root, name)
      path = File.join(missions_root, name, "MISSION.md")
      File.exist?(path) ? new(name: name, source: File.read(path)) : nil
    end

    def initialize(name:, source:)
      @name = name
      @source = source
    end

    attr_reader :name

    # Basename of the backtick-quoted path on the "Target repo:" line, or nil for a kata.
    def target
      path = backticked_after("Target repo")
      path&.empty? ? nil : path && File.basename(path)
    end

    # github-project shape fields (backtick-quoted on their own line, or nil if absent).
    def gh_repo = backticked_after("GH repo")
    def gh_project = backticked_after("GH project")
    def epic = backticked_after("Epic")

    # External-target missions are professional work; self-contained katas are personal.
    def realm
      target ? "professional" : "personal"
    end

    private

    attr_reader :source

    # The first backtick-quoted value on the line that names `label:`, or nil.
    def backticked_after(label)
      line = source.lines.find { |l| l.include?("#{label}:") }
      line&.match(/`([^`]+)`/)&.captures&.first&.strip
    end
  end
end
