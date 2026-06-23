# Workshop

A practice space for deliberate reps on software craft — anatomy-first OO, GOOS
outside-in TDD, and a [hardened testing discipline](docs/DISCIPLINE.md). You drill a slice's
design on paper (the [rock drill](ROCK_DRILL_PROTOCOL.md)), then pair with an AI to build it
under an explicit [pairing mode](PAIRING_PROTOCOL.md). The point is the *form* of the
practice, not the output.

It is **editor-agnostic** (works with VS Code, Cursor, Emacs, Vim, or no editor at all) and
**portable** across macOS and Linux.

## Quickstart

```bash
git clone <this-repo> workshop && cd workshop
bin/doctor                                          # check deps + config
bin/workshop examples/conway-game-of-life/SLICE_01_walking_skeleton
```

`bin/doctor` tells you what's installed and what's missing, with install hints for your OS.
The `bin/workshop` command prints (or wires up) the three things every slice needs: an
**editor**, a **watcher** running the tests, and an **AI pair**.

## Learn the workshop

New here? Read these two, in order — they take you from "what are all these words" to
"shipping real work":

1. **[docs/CONCEPTS.md](docs/CONCEPTS.md)** — the mental model: mission → slice → drill →
   code, the two TDD loops, the five pairing modes and the signals you drive them with, and
   how the framework stays separate from your content. Read once.
2. **[docs/WORKFLOWS.md](docs/WORKFLOWS.md)** — three deep, end-to-end walkthroughs for the
   three kinds of work:
   - a **self-contained kata** (like the bundled Conway) — learn a technique in isolation;
   - an **external-target mission** (like working on a real Rails app) — drill here, code lands
     in another repo;
   - a **GitHub-project mission** — work tracked as GitHub Issues on a Projects board, driven
     by `bin/issue`.

Reference docs: **[docs/DISCIPLINE.md](docs/DISCIPLINE.md)** (the anatomy frame, §1–§6, Sandi's
rules, the registry seam — the craft the workshop drills),
[PAIRING_PROTOCOL.md](PAIRING_PROTOCOL.md) (modes + signals),
[ROCK_DRILL_PROTOCOL.md](ROCK_DRILL_PROTOCOL.md) (the seven-station drill), and
[GITHUB_PROJECT_SHAPE.md](GITHUB_PROJECT_SHAPE.md) (the GitHub binding). The bundled
[`examples/conway-game-of-life`](examples/conway-game-of-life) is a fully-drilled mission to
read end to end.

## The flow

By default `bin/workshop <slice>` uses the `manual` launcher — it just prints the commands
to run, so it works in any editor with zero setup:

```
1. open the slice folder in your editor
2. in a terminal:  cd <slice> && bin/watch      # re-runs tests on save
3. in a terminal:  cd <slice> && claude         # or your AI of choice
```

Prefer your editor to wire that up for you? Set a **launcher** (see below).

## Configure (per machine)

Copy the example and edit — `.workshoprc.local` is gitignored, so your machine-specific
choices never get committed:

```bash
cp .workshoprc.local.example .workshoprc.local
```

Two knobs matter most:

| Setting | What it does |
|---------|--------------|
| `WORKSHOP_LAUNCHER` | `manual` (default), `tmux`, `vscode`, `cursor`, or `emacs` |
| `WORKSHOP_CONTENT_DIR` | where *your* missions and notes live (see below) |

The committed `.workshoprc` holds shared defaults; `.workshoprc.local` overrides them per
machine; a per-slice `.workshoprc` overrides both. (macOS users on the `vscode`/`cursor`
launcher: run *"Shell Command: Install 'code' command in PATH"* once so the CLI works.)

## Keep your own practice content separate

The framework (this repo) and your practice content (missions, notes) are two different
things. Point `WORKSHOP_CONTENT_DIR` at a separate repo and the tooling — `bin/new-rep`,
`bin/new-slice`, `bin/note` — reads and writes there instead of inside this clone:

```bash
# in .workshoprc.local
export WORKSHOP_CONTENT_DIR="$HOME/src/workshop-personal"
```

Unset, it defaults to this repo's root — fine if you just want to try things. The bundled
`examples/` always launch from here regardless.

## Start a mission

```bash
bin/new-rep my-mission                 # scaffold MISSION.md (drill stations 1–2)
bin/new-slice my-mission skeleton       # scaffold the first slice (drill stations 3–7)
bin/drill-check my-mission/SLICE_01_skeleton
bin/workshop my-mission/SLICE_01_skeleton
```

Slice 1 of any mission is always the [walking skeleton](ROCK_DRILL_PROTOCOL.md). That's the
kata shape; for working in an existing repo or against GitHub Issues, follow the
external-target and github-project walkthroughs in
[docs/WORKFLOWS.md](docs/WORKFLOWS.md).

## Requirements

- **Ruby** (a recent version; `mise.toml` pins one if you use [mise](https://mise.jdx.dev/))
- **[entr](https://eradman.com/entrproject/)** — the file watcher (`brew install entr` /
  `apt install entr` / `pacman -S entr`)
- **Optional:** your launcher's editor (`tmux`, `code`, `cursor`, `emacs`); `gh` (with the
  `project` scope) only for github-project missions

Run `bin/doctor` to verify all of it.

## Layout

```
bin/            CLI: new-rep, new-slice, workshop, watch, drill-check, note, issue, doctor
bin/launchers/  workspace launchers: manual, tmux, vscode, cursor, emacs
lib/  test/     the Workshop Ruby library + its tests
templates/      scaffolds for missions, slices, and notes
examples/       worked example missions (start with conway-game-of-life)
docs/           CONCEPTS.md (mental model) · WORKFLOWS.md (walkthroughs) · DISCIPLINE.md (the craft)
*.md            the protocols (PAIRING, ROCK_DRILL, GITHUB_PROJECT_SHAPE) + CLAUDE bootstrap
```
