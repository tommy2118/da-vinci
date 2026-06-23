# frozen_string_literal: true

module Workshop
  module Rules
    class RequiredFilesRule
      REQUIRED_FILES = {
        "ANATOMY.md" => :anatomy_path,
        "spec/acceptance_spec.rb" => :acceptance_spec_path
      }.freeze

      def call(slice)
        missing = REQUIRED_FILES.filter_map do |label, message|
          label unless File.exist?(slice.public_send(message))
        end

        if missing.empty?
          CheckResult.new(true, "required files present")
        else
          CheckResult.new(false, "missing files: #{missing.join(', ')}")
        end
      end
    end
  end
end
