# frozen_string_literal: true

module Workshop
  class Slice
    ANATOMY_PATH = "ANATOMY.md"
    ACCEPTANCE_SPEC_PATH = File.join("spec", "acceptance_spec.rb")
    WORKSHOPRC_PATH = ".workshoprc"
    TARGET_REPO_LINE = /\A\s*WORKSHOP_TARGET_REPO=(.*)$/

    def initialize(path)
      @path = File.expand_path(path)
    end

    attr_reader :path

    def anatomy_path
      File.join(path, ANATOMY_PATH)
    end

    def acceptance_spec_path
      File.join(path, ACCEPTANCE_SPEC_PATH)
    end

    def anatomy
      read(anatomy_path)
    end

    def acceptance_spec
      read(acceptance_spec_path)
    end

    # The target repo set in this slice's .workshoprc, or nil when self-contained.
    def target_repo
      read(File.join(path, WORKSHOPRC_PATH)).each_line do |line|
        next if line.match?(/\A\s*#/)
        next unless (match = line.match(TARGET_REPO_LINE))

        value = match[1].strip.gsub(/\A["']|["']\z/, "")
        return value.empty? ? nil : value
      end
      nil
    end

    def external_target?
      !target_repo.nil?
    end

    private

    def read(file_path)
      File.exist?(file_path) ? File.read(file_path) : ""
    end
  end
end
