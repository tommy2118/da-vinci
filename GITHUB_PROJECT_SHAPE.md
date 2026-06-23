# GitHub-project shape

Some target repos keep their **unit of work in GitHub**: Epics and Task issues, labelled
`type:` / `priority:` / `phase:`, tracked on a Projects v2 board, with commits that reference
`(#nn)`. This document is the contract for drilling such a project from the workshop. It layers on top of
`PAIRING_PROTOCOL.md` → External-target missions — read that first; nothing there changes.

## The mapping

| Workshop        | GitHub                          | Notes                                                        |
|-----------------|---------------------------------|-------------------------------------------------------------|
| Mission         | **Epic** issue                  | A body of work that decomposes into slices.                 |
| Slice           | **Task** issue                  | A 1–2 day unit; gets its own rock drill.                    |
| P-Cubed phase   | `phase:prepare/prove/produce`   | The issue's phase label *is* the P-Cubed phase.             |
| Slice commit(s) | `… (#nn)` referencing the Task  | Match the target's own commit convention.                   |
| PR for a slice  | `Closes #nn`                    | One slice → one PR → card moves to In Review → Done on merge.|

This is the same Levels table from the global `CLAUDE.md` (Epic → decompose → Tasks),
expressed in GitHub's nouns.

## Where the wiring lives

- **`MISSION.md`** (the Epic) carries three backtick-quoted fields: `Epic:`, `GH repo:`,
  `GH project:`. `bin/issue mission <epic-n>` fills them.
- **The slice `.workshoprc`** carries `WORKSHOP_GH_ISSUE="<task-n>"`. `bin/issue slice
  <mission> <task-n>` sets it and drops the issue's Given/When/Then into the slice's
  `ANATOMY.md` scratch.
- **`bin/issue` is the only thing that talks to GitHub**, and it does so only through
  `Workshop::Github::Cli` (the one object that shells out to `gh`). No controller, no other
  script, reaches for `gh` directly — that is the "no second nervous system" rule, enforced
  by structure: `bin/issue → Workshop::Github::Gateway → Workshop::Github::Cli → gh`.

## `bin/issue` commands

```
bin/issue show <n>                     # print one issue (title, labels, body)
bin/issue epic <n>                     # print an epic + the Task issues that reference it
bin/issue mission <epic-n> [name] \    # scaffold a mission from an Epic (bin/new-rep + fill fields)
          --target ~/src/<repo>
bin/issue slice <mission> <task-n>     # scaffold a slice from a Task (bin/new-slice + issue context)
bin/issue create "<title>" \           # create a Task issue, label it, add it to the board
          --label type:task --label phase:produce --status Todo [--body B --no-board --yes]
bin/issue board <n> "<status>" [--yes] # move the issue's card (Backlog/Todo/In Progress/In Review/Done/Blocked)
bin/issue pr <n> --head <branch> [--yes]  # open a PR that closes the issue, then card → In Review
```

Repo and project resolve in this order: explicit `--repo`/`--project` flags → `WORKSHOP_GH_REPO`
/ `WORKSHOP_GH_PROJECT` env → the nearest `MISSION.md` fields (walking up from the cwd, the
same way `bin/note` infers the active mission).

## Outward writes are confirmed, not automatic

`create`, `board`, and `pr` write to GitHub — they are outward-facing and visible to anyone
watching the project. They **dry-run by default** and only execute with `--yes`. In a pairing session that
means: propose the move, get the user's nod, *then* pass `--yes`. The board transitions that fall
out of the loop:

- Start a slice → `board <n> "In Progress"`.
- Open the slice's PR → `pr <n>` (moves the card to **In Review** on success).
- PR merged → `board <n> "Done"`.

## Workshop leads — but never contradicts the target

The workshop's protocol governs *how we work* (drill first, skeleton first, §1–§6, the modes
and signals). The target repo's own `AGENTS.md` / `CLAUDE.md` / ADRs govern *the code itself*.
Defer to them where they speak, and never let the workshop's habits override:

- **Test command** — use the target's (`make test`, `docker compose run … rspec …`), wired
  through `WORKSHOP_TEST_CMD`.
- **Commit / PR convention** — imperative subject, body explains *why*, reference `(#nn)`.
- **ADR invariants** — load-bearing decisions (e.g. Chronicler ≠ Subject, Pressure keyed to
  Location, consent-as-events). A slice that would erode an ADR is a stop-and-surface, not a
  quiet change.

If the workshop protocol and a target ADR ever genuinely conflict, that is an anatomical
decision — surface it to the user, don't resolve it unilaterally.

## Starting a github-project mission

```
# 1. Scaffold the mission from the Epic (fills Epic/GH repo/GH project; lists candidate Tasks).
bin/issue mission 5 my-mission --target "$HOME/src/my-target-repo" \
  --repo your-org/your-repo --project 4

# 2. Drill stations 1–2 in my-mission/MISSION.md (the slice list is yours — no drilling ahead).

# 3. Scaffold slice 1 from its Task issue; finish the per-slice .workshoprc (target test cmd, watch glob).
bin/issue slice my-mission 12

# 4. Drill stations 3–7 in the slice's ANATOMY.md, then bin/drill-check, then bin/workshop.
```
