# frozen_string_literal: true

# In-memory stand-in for Workshop::Github::Cli. Mirrors its public interface so the Gateway
# can be driven without touching the network or `gh`. Records outgoing commands (edit_item,
# create_pr) so tests can assert the side effect (§5: a fake, not a pile of mocks).
class FakeGhCli
  attr_reader :edits, :prs, :created, :added

  def initialize(issues: {}, project: {}, items: [], fields: [],
                 new_issue_url: "https://github.com/example/repo/issues/42", new_item: { "id" => "ITEM_new" })
    @issues = issues       # number => json hash
    @project = project     # { "id" => ... }
    @items = items         # [ { "id" => ..., "content" => { "number" => n } } ]
    @fields = fields       # [ { "id" => ..., "name" => ..., "options" => [...] } ]
    @new_issue_url = new_issue_url
    @new_item = new_item
    @edits = []
    @prs = []
    @created = []
    @added = []
  end

  def issue(number)
    @issues.fetch(Integer(number)) { raise Workshop::Github::Error, "no such issue ##{number}" }
  end

  def issue_list(labels: [], state: "open", limit: 100)
    @issues.values.select do |hash|
      names = Array(hash["labels"]).map { |l| l.is_a?(Hash) ? l["name"] : l }
      labels.all? { |label| names.include?(label) }
    end
  end

  def project_view(_number, _owner) = @project

  def project_items(_number, _owner, limit: 200) = @items

  def project_fields(_number, _owner) = @fields

  def edit_item(project_id:, item_id:, field_id:, option_id:)
    @edits << { project_id:, item_id:, field_id:, option_id: }
    nil
  end

  def create_pr(title:, body:, base:, head:)
    @prs << { title:, body:, base:, head: }
    "https://github.com/example/repo/pull/1"
  end

  def create_issue(title:, body:, labels:)
    @created << { title:, body:, labels: }
    @new_issue_url
  end

  def add_project_item(_number, _owner, url)
    @added << url
    @new_item
  end
end
