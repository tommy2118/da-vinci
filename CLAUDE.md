# Workshop — Claude Bootstrap

This is a **practice space**, not a project. The point is deliberate reps on the craft (anatomy-first OO, GOOS outside-in TDD, §1–§6 enforcement, Sandi's rules). Output matters less than the form of the practice.

## On session start, read in this order

These files live at the workshop root (the directory holding this `CLAUDE.md`), except where a
`docs/` path is given:

1. `docs/DISCIPLINE.md` — the craft you're pairing on: the anatomy frame, GOOS §1–§6, Sandi's rules, the registry seam. This governs the code you help write.
2. `PAIRING_PROTOCOL.md` — the modes and signals you respond to.
3. `ROCK_DRILL_PROTOCOL.md` — the seven-station rehearsal run before any non-trivial slice.
4. `.workshoprc` — global defaults for the workshop (and `.workshoprc.local`, per-machine overrides, if present).
5. If the current working directory contains a `.workshoprc`, source it as overrides on top of the global.
6. If the current working directory contains an `ANATOMY.md`, read it to know where the in-flight slice stands. If instead you're in a mission directory in `scout` mode (a discovery session opened by `bin/start`: a `MISSION.md` but no slice yet), read `MISSION.md`'s Station 0 to know what problem you're researching.
7. If a mission is active, skim `notes/INDEX.md` (and `bin/note find --mission <name>` / `--target <repo>`) for durable findings, decisions, gotchas, and lessons bearing on it. See `PAIRING_PROTOCOL.md` → Engineering notes. (Notes and missions live under `WORKSHOP_CONTENT_DIR`, which defaults to the workshop root.)
8. If the active mission or slice sets `WORKSHOP_GH_REPO` (a github-project mission), read `GITHUB_PROJECT_SHAPE.md` and skim the active Epic/Task via `bin/issue show $WORKSHOP_GH_ISSUE`.

## After reading, confirm

In your first reply of the session, state:
- The active **mode** (from `WORKSHOP_MODE`, possibly overridden per-slice).
- The **signal vocabulary** that applies (universal + any mode-specific).
- **Where we left off**: the verification checkboxes in ANATOMY.md, last commit message, current red/green state. In a `scout` discovery session, it's the Station 0 problem and the findings recorded so far.

Then wait for a signal. Do not act until one is issued.

## Hard constraints

- The discipline in `docs/DISCIPLINE.md` governs the code; re-read it if you're uncertain about a principle. The user's global `~/.claude/CLAUDE.md`, if present, applies on top.
- No implementation begins without a drilled `ANATOMY.md` in the slice directory.
- Slice 1 of any mission is the walking skeleton. Always.
- Mode-specific rules (what you may/may not edit, when you may write code) live in `PAIRING_PROTOCOL.md`. Defer to that document; do not re-derive its rules from memory.
- Workshop infrastructure (`bin/`, `templates/`, `*.md` at workshop root, `.workshoprc` files) is exempt from mode constraints — it's tooling, not the practice.

## How to think about extension

Anything that doesn't fit the existing modes/signals/templates is a signal that the system needs an extension, not a workaround. Surface the gap to the person you're pairing with and propose where it would live (which file gets a new section, which template gets a new field). Don't smuggle ad-hoc behavior past the protocol.

Durable engineering knowledge you uncover — a finding, decision, gotcha, or lesson — becomes a note in `notes/` via `bin/note`, not an inline comment or a bloated MISSION cell. See `PAIRING_PROTOCOL.md` → Engineering notes.
