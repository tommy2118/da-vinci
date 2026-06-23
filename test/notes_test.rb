# frozen_string_literal: true

require_relative "test_helper"
require "tmpdir"
require "date"

class NotesTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  FIXTURES = File.join(ROOT, "test", "fixtures", "notes")

  # --- Workshop::Note: parse + validate one file ---

  def test_note_rejects_missing_frontmatter
    assert_raises(Workshop::Note::InvalidNote) { note_from("no frontmatter here\n") }
  end

  def test_note_rejects_invalid_type
    assert_raises(Workshop::Note::InvalidNote) { note_from(frontmatter(type: "musing")) }
  end

  def test_note_rejects_invalid_status
    assert_raises(Workshop::Note::InvalidNote) { note_from(frontmatter(status: "pending")) }
  end

  def test_note_rejects_invalid_realm
    assert_raises(Workshop::Note::InvalidNote) { note_from(frontmatter(realm: "corporate")) }
  end

  def test_note_allows_missing_target
    note = Workshop::Note.new(fixture("bloated-mission-cell-is-a-note.md"))

    assert_nil note.target
  end

  def test_note_defaults_optional_arrays_to_empty
    note = Workshop::Note.new(fixture("ledger-entry-validates-intent.md"))

    assert_equal [], note.tags
    assert_equal [], note.links
  end

  def test_note_slug_comes_from_file_name_not_title
    note = Workshop::Note.new(fixture("slug-differs-from-title.md"))

    assert_equal "slug-differs-from-title", note.slug
    refute_equal note.slug, note.title
  end

  # --- Workshop::NotesCorpus: enumerate + compose filters/search ---

  def test_corpus_ignores_index_markdown
    refute_includes corpus.notes.map(&:slug), "INDEX"
  end

  def test_corpus_where_composes_with_search
    in_mission = corpus.where(mission: "checkout")
    assert_equal 2, in_mission.size

    matched = corpus.search("idempotency", notes: in_mission)
    assert_equal ["checkout-double-submit-is-latent"], matched.map(&:slug)
  end

  # --- Workshop::NotesIndex: render discovery output ---

  def test_index_groups_by_realm_then_mission_then_type
    md = index

    # Realms ordered professional before personal.
    assert_operator md.index("## Professional"), :<, md.index("## Personal")
    # Missions alphabetical within a realm.
    assert_operator md.index("### checkout"), :<, md.index("### workshop")
    # Types in canonical order within a mission (decision before finding).
    assert_operator md.index("#### decision"), :<, md.index("#### finding")
  end

  def test_index_line_carries_wikilink_and_path
    md = index

    assert_includes md, "[[checkout-double-submit-is-latent]] — The double-submit is latent, not live"
    assert_includes md, "notes/checkout-double-submit-is-latent.md"
  end

  def test_index_line_includes_meta_facets
    line = meta_line(index, "checkout-double-submit-is-latent")

    assert_includes line, "`status: open`"
    assert_includes line, "`slice: 02`"
    assert_includes line, "`target: storefront`"
    assert_includes line, "`tags: billing, idempotency`"
  end

  def test_index_omits_optional_facets_when_absent
    line = meta_line(index, "ledger-entry-validates-intent")

    assert_includes line, "`status: n/a`"
    assert_includes line, "`target: storefront`"
    refute_includes line, "slice:"
    refute_includes line, "tags:"
  end

  # --- Workshop::NoteScaffold: build a new note (the write path) ---

  def test_scaffold_quotes_slice_status_and_created
    note = built(title: "Demo", type: "finding", mission_name: "checkout", slice: "02")

    # Round-trips through Note (i.e. through YAML.safe_load) with the quoted values intact.
    assert_equal "02", note.slice
    assert_equal "open", note.status
    assert_equal "2026-06-05", note.created
  end

  def test_scaffold_defaults_status_by_type
    assert_equal "accepted", built(title: "D", type: "decision").status
    assert_equal "open", built(title: "F", type: "finding").status
    assert_equal "n/a", built(title: "R", type: "reference").status
    assert_equal "n/a", built(title: "L", type: "lesson").status
  end

  def test_scaffold_derives_target_from_active_mission
    note = built(title: "Uncovered here", mission: mission_with_target)

    assert_equal "storefront", note.target
    assert_equal "professional", note.realm
    assert_equal "checkout", note.mission
  end

  def test_scaffold_falls_back_when_no_active_mission_exists
    note = built(title: "Ad hoc thought") # no mission collaborator

    assert_equal "workshop", note.mission
    assert_equal "personal", note.realm
    assert_nil note.target
    assert_equal "finding", note.type
    assert_equal "open", note.status
  end

  def test_scaffold_collision_gets_numeric_suffix
    first = scaffold.build({ title: "Same idea", mission: "workshop" })
    second = scaffold.build({ title: "Same idea", mission: "workshop" }, existing_slugs: [first[:slug]])

    assert_equal "same-idea", first[:slug]
    assert_equal "same-idea-2", second[:slug]
  end

  def test_scaffold_adds_decision_section_only_for_decisions
    decision = scaffold.build({ title: "A call", type: "decision" })
    finding = scaffold.build({ title: "A fact", type: "finding" })

    assert_includes decision[:content], "## Decision / alternatives"
    refute_includes finding[:content], "## Decision / alternatives"
  end

  private

  TEMPLATE = File.read(File.join(ROOT, "templates", "note.md.tmpl"))
  FakeClock = Struct.new(:date) { def today = date }

  def scaffold(mission: nil)
    Workshop::NoteScaffold.new(
      template: TEMPLATE,
      clock: FakeClock.new(Date.new(2026, 6, 5)),
      mission: mission
    )
  end

  # Build via the scaffold, then load the output as a real Note — proving the generated
  # frontmatter is valid and round-trips through YAML.
  def built(title:, type: "finding", realm: nil, mission_name: nil, slice: nil, mission: nil)
    attrs = { title: title, type: type }
    attrs[:realm] = realm if realm
    attrs[:mission] = mission_name if mission_name
    attrs[:slice] = slice if slice

    result = scaffold(mission: mission).build(attrs)
    Dir.mktmpdir do |dir|
      path = File.join(dir, "#{result[:slug]}.md")
      File.write(path, result[:content])
      return Workshop::Note.new(path)
    end
  end

  def mission_with_target
    Workshop::Mission.new(name: "checkout", source: "**Target repo:** `$HOME/src/storefront` — x")
  end

  def index
    Workshop::NotesIndex.new(corpus).render
  end

  # The meta line is the indented line immediately under a note's "[[slug]]" bullet.
  def meta_line(markdown, slug)
    lines = markdown.lines
    bullet = lines.index { |l| l.include?("[[#{slug}]]") }
    lines.fetch(bullet + 1)
  end

  def corpus
    Workshop::NotesCorpus.new(FIXTURES)
  end

  def fixture(name)
    File.join(FIXTURES, name)
  end

  # Invalid notes are written to a temp file so they never pollute the fixture corpus.
  def note_from(content)
    Dir.mktmpdir do |dir|
      path = File.join(dir, "scratch-note.md")
      File.write(path, content)
      return Workshop::Note.new(path)
    end
  end

  def frontmatter(type: "finding", realm: "professional", status: "open")
    <<~MD
      ---
      title: "Scratch"
      type: #{type}
      realm: #{realm}
      mission: workshop
      status: "#{status}"
      created: "2026-06-05"
      ---

      # Scratch
      body
    MD
  end
end
