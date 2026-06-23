# frozen_string_literal: true

module Workshop
  # The github-project shape: the unit of work lives in GitHub Issues + a Projects v2 board.
  # Epic issue ↔ mission, Task issue ↔ slice, phase labels ↔ P-Cubed. See GITHUB_PROJECT_SHAPE.md.
  module Github
    Error = Class.new(StandardError)

    # One GitHub issue, normalized. Refuses to know how `gh` shapes its JSON — built from a
    # plain hash by Issue.from_json so the parsing lives in exactly one place.
    Issue = Data.define(:number, :title, :body, :labels, :url, :state) do
      def self.from_json(hash)
        new(
          number: Integer(hash.fetch("number")),
          title: hash.fetch("title"),
          body: hash["body"].to_s,
          labels: Array(hash["labels"]).map { |l| l.is_a?(Hash) ? l.fetch("name") : l },
          url: hash["url"],
          state: hash["state"]
        )
      end

      # The value of a "prefix:value" label (e.g. label_value("phase") => "prove"), or nil.
      def label_value(prefix)
        labels.find { |l| l.start_with?("#{prefix}:") }&.split(":", 2)&.last
      end

      def kind = label_value("type")
      def phase = label_value("phase")
      def priority = label_value("priority")

      # The epic short-code in the title (e.g. "E5" from "E5 Correlation view"), or nil.
      def epic_code
        title[/\bE\d+\b/]
      end
    end
  end
end

require_relative "github/cli"
require_relative "github/gateway"
