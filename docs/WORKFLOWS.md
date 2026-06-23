# Da Vinci workflows: three end-to-end walkthroughs

This is the *doing* guide. It assumes you've skimmed [CONCEPTS.md](CONCEPTS.md) for the
vocabulary (mission, slice, drill, mode, signal, content dir, launcher).

Every mission follows the same spine:

```
new-rep → drill stations 1–2 (MISSION.md)
        → new-slice → drill stations 3–7 (ANATOMY.md) → acceptance stub
        → drill-check → workshop → pair the code green → commit → next slice
```

The three walkthroughs differ only in **where the code lands** and **how the work is
tracked**:

1. [A self-contained kata](#1-a-self-contained-kata): code lives in the slice. Learn a technique.
2. [An external-target mission](#2-an-external-target-mission): code lands in another repo. Real work on an existing codebase.
3. [A GitHub-project mission](#3-a-github-project-mission): work tracked as GitHub Issues on a Projects board. A side project, or any GitHub-managed repo.

Before any of them, run `bin/doctor` once to confirm your tools, and decide where your content
lives (see [CONCEPTS → two-repo model](CONCEPTS.md#framework-vs-content-the-two-repo-model)).
The finished reference for everything below is
[`examples/conway-game-of-life`](../examples/conway-game-of-life).

---

## 1. A self-contained kata

**When:** you want to drill a technique (a pipeline, a value object, a substitution seam) in
isolation, with nothing else in the way. The slice directory *is* a small Ruby project.

We'll follow the bundled **Conway's Game of Life** example. It's finished and fully drilled,
so you can open every artifact this walkthrough describes, and run the last two steps against
it yourself. When you build your *own* kata the commands are identical; only the names change.

### Step 1: Scaffold the mission

```bash
bin/new-rep conway-game-of-life
```
```
Created <content-dir>/conway-game-of-life/
  <content-dir>/conway-game-of-life/MISSION.md
Next:
  1. Edit MISSION.md: drill stations 1 (mission statement) and 2 (slice list).
  2. bin/new-slice conway-game-of-life <slice-name>   # creates SLICE_01_<slice-name>/
```

> The bundled copy lives under `examples/conway-game-of-life`, so you can read it without
> building anything. Running `bin/new-rep` puts a fresh one in *your* content dir.

### Step 2: Drill stations 1–2 (the mission)

Open `MISSION.md` and fill the two stations. **Station 1** is one sentence, behavior in →
behavior out, no implementation words. **Station 2** is 3–5 slices ordered by *risk*, skeleton
first. Conway's looks like this ([real file](../examples/conway-game-of-life/MISSION.md)):

```markdown
## Station 1: Mission
Given a Grid of live cells -> return the next Grid by applying Conway's birth/survival rules.

## Station 2: Slice list
1. walking skeleton: blinker tick
   Risk first: the rule pipeline (count neighbours -> apply rules -> emit grid) isn't wired end to end.
   Proof: a vertical blinker becomes a horizontal blinker after one tick.
2. rule engine handles all 4 cases  (under-population, survival, over-population, birth)
3. bounded vs. toroidal grid topology  (swap the grid behind one port; acceptance still passes)
```

Notice the ordering is by *risk*: the riskiest unknown, "is the pipeline even wired?", ships
first as the skeleton; correctness and topology come after.

> **No drilling ahead.** Only stations 1–2 now. Each slice gets its own drill *when you reach
> it*. Pre-designing slice 3 today wastes the rep and usually guesses wrong.

### Step 3: Scaffold slice 1 (the walking skeleton)

```bash
bin/new-slice conway-game-of-life walking_skeleton
```
```
Created <content-dir>/conway-game-of-life/SLICE_01_walking_skeleton/
  …/ANATOMY.md              (drill stations 3-7)
  …/spec/acceptance_spec.rb (the artifact that ends the drill)
  …/.workshoprc             (per-slice overrides)
```

### Step 4: Drill stations 3–7 (the anatomy)

Open `SLICE_01_walking_skeleton/ANATOMY.md`. The generated file is a guided template: each
section carries a "how to think / heuristic / watch for" coaching block. Work the five
sections, and read Conway's finished version next to yours
([real file](../examples/conway-game-of-life/SLICE_01_walking_skeleton/ANATOMY.md)). What it
drilled:

- **Collaborators**: `[C] TickRequester → [O] GameOfLife#tick(grid:) → [R] NextGrid`, with
  `GameOfLife` asking a `[P] NeighbourQuery` port (real default `[A] BoundedGridAdapter`) for
  live-neighbour counts, over an immutable `[V] Grid`. Six boxes, every arrow named.
- **Joints**: `GameOfLife.new` is the real default; the neighbour port is injected so a test
  can swap a fake. Each arrow lists its real default *and* its test double.
- **Refusals**: e.g. `GameOfLife` does NOT know how cells are stored or the grid topology;
  `BoundedGridAdapter` does NOT know Conway's rules. Six refusal lists. This is where the
  design lives.
- **Walk-through**: the blinker traced message-by-message, plus one failure (a zero-dimension
  grid raises before any neighbour call).
- **Bypass risks**: three named, e.g. "`GameOfLife` inlines neighbour counting and leaks
  bounded-grid assumptions," mitigated by the slice-3 acceptance test swapping a toroidal grid.

Want a guided rehearsal first? `bin/rockdrill-visual` opens a browser tool that walks stations
1–7 with a shared symbol grammar and exports the artifacts. Optional, but good for your first
few drills.

### Step 5: Write the acceptance stub (this ends the drill)

The generated `spec/acceptance_spec.rb` has a `pending` placeholder. Replace it with the
happy-path assertion you traced in station 6: for Conway, *a vertical blinker becomes a
horizontal blinker after one tick*. The right shape of red is a **real assertion failure**
(`tick` returns the wrong grid), not a `NameError` from missing plumbing.

### Step 6: Static-audit the drill

Run this against the bundled example to see a green report:

```bash
bin/drill-check examples/conway-game-of-life/SLICE_01_walking_skeleton
```
```
PASS: required files present
PASS: required anatomy sections present
PASS: verification checklist is complete
PASS: refusal lists cover each object
PASS: bypass audit names 3 risks
PASS: acceptance spec asserts real behavior
```
It checks the drill's *shape* (sections, checklist, ≥3 risks, no leftover placeholder). It does
**not** run your acceptance test. That's the next step.

### Step 7: Open the workbench and pair it green

```bash
bin/workshop examples/conway-game-of-life/SLICE_01_walking_skeleton
```
This opens your editor, a **watcher** (`bin/watch` re-runs the tests on every save), and an
**AI pair**. The AI's cwd is the slice, so it auto-loads the workshop bootstrap, reads the
`ANATOMY.md`, and reports the active **mode** and where you are.

Now drive with [signals](CONCEPTS.md#signals--how-you-talk-to-the-ai). A kata is a great place
for `navigator` (you type every move, Claude prescribes) or `ping-pong` (you write a red test,
Claude writes the dumb pass, you refactor). Set the mode in the slice's `.workshoprc`
(`WORKSHOP_MODE=ping-pong`) or switch live with `mode ping-pong`. A typical rhythm:

```
you:    [write the red blinker assertion: vertical blinker → horizontal blinker after one tick]
you →   run
claude: (runs the spec) red: GameOfLife#tick returned an empty grid, expected the horizontal blinker
you →   next
claude: Move 1: in lib/game_of_life.rb, define GameOfLife#tick(grid:) returning the hard-coded
        horizontal-blinker Grid. Save.
you:    [type it]
you →   green
claude: green: the skeleton walks end to end. The hard-coded grid is the point: slice 2 (rule
        engine) makes tick earn that output instead of faking it.
```

The skeleton is green when the acceptance test passes with the dumbest possible code: here, a
**hard-coded** next grid. That "cheat" is the proof the pipeline is wired; the next slice
replaces it with the real rule engine.

### Step 8: Commit the slice, then drill the next one

Each slice is its own commit. Then `bin/new-slice conway-game-of-life rule_engine`, drill
*its* stations 3–7, and repeat (slice 3 is `topology`). The walking skeleton's acceptance test
stays green forever; later slices add tests by addition, never by mutation.

---

## 2. An external-target mission

**When:** you're doing real work on an existing codebase, say a Rails app like `storefront`. You
still drill in the workshop, but the **code and the real acceptance test land in the target
repo**. The drill artifacts (`MISSION.md`, `ANATOMY.md`) stay in the workshop; the
implementation lives where it belongs.

The shape is identical to the kata: the only differences are the **mission's target field**,
the **slice `.workshoprc`** (which points the runner at the target), and the **acceptance
spec** (a real spec in the target, not a stub against fakes). See
[PAIRING_PROTOCOL → External-target missions](../PAIRING_PROTOCOL.md#external-target-missions).

### Step 1: Scaffold and set the target

```bash
bin/new-rep order-webhook
```
In `order-webhook/MISSION.md`, set the target repo and drill stations 1–2 as usual:

```markdown
**Target repo:** `$HOME/src/storefront`
```
Using `$HOME` (never a hardcoded `/home/you`) keeps the mission portable across your machines.
The presence of a target repo is also what marks the mission's notes as `professional` realm.

### Step 2: Scaffold slice 1 and point its `.workshoprc` at the target

```bash
bin/new-slice order-webhook walking_skeleton
```
Edit `SLICE_01_walking_skeleton/.workshoprc` so the watcher and runner operate **on the
target**. No runner code changes, just config:

```bash
# Code lives in another repo. Open the editor/term there; watch + AI keep the slice as cwd.
WORKSHOP_MODE=true-pair
WORKSHOP_TARGET_REPO="$HOME/src/storefront"
WORKSHOP_TEST_CMD="cd $HOME/src/storefront && bin/rspec spec/requests/webhooks/order_webhook_spec.rb"
WORKSHOP_WATCH_GLOB="$HOME/src/storefront/app $HOME/src/storefront/spec"
```

If the target runs its specs in Docker, exec into the container in the test command and log the
`term` window in via the target's make task:

```bash
WORKSHOP_TEST_CMD="cd $HOME/src/storefront && docker compose run --rm web bin/rspec spec/requests/webhooks/order_webhook_spec.rb"
WORKSHOP_TERM_CMD="cd $HOME/src/storefront && make login"
```

### Step 3: Drill, but make the skeleton walk the *real* stack

Drill stations 3–7 in `ANATOMY.md` as normal. The crucial difference is the acceptance test:
for an external-target skeleton, **the real acceptance test is a real spec in the target repo**
(e.g. `storefront/spec/requests/webhooks/order_webhook_spec.rb`), exercising the target's real
router, DB, and wiring: only the true external edges (Stripe, etc.) faked at the
[registry seam](DISCIPLINE.md#the-adapter-registry). That's what keeps the skeleton honest.

The slice's own `spec/acceptance_spec.rb` becomes a **one-line pointer** to that real spec
(since `bin/drill-check` can't run the target's suite). `drill-check` still audits stations
3–7.

### Step 4: Open the workbench on the target

```bash
bin/workshop order-webhook/SLICE_01_walking_skeleton
```
With `WORKSHOP_TARGET_REPO` set, the launcher opens your **editor and term in the target repo**
(where the code is) and gives a `claude` AI pane `--add-dir <target>` so it can edit there,
while the watcher and AI keep the slice as cwd, so the per-slice `.workshoprc` and the workshop
protocol still load. The drill artifacts stay readable from the AI pane by path.

### Step 5: Pair the slice green, in the target's conventions

`true-pair` is the usual mode here: you drive, Claude takes bounded hand-offs (`take this`),
reviews diffs with `file:line`, and carries the manual end-to-end verification. Follow the
**target repo's** own rules: its test command, its commit/PR convention, its `AGENTS.md`/ADR
invariants. The workshop governs *how you work*; the target governs *the code itself*. A change
that would erode one of the target's load-bearing decisions is a stop-and-surface, not a quiet
edit.

Commit per slice (in the target repo), then drill the next slice.

---

## 3. A GitHub-project mission

**When:** the work's **unit of record lives in GitHub**: Epics and Task issues on a Projects
v2 board. Perfect for a side project, or any repo managed with GitHub Issues + Projects. This
is an external-target mission *plus* a GitHub binding: **Epic = mission, Task = slice**, and
`bin/issue` is the only thing that talks to GitHub. Full contract:
[GITHUB_PROJECT_SHAPE.md](../GITHUB_PROJECT_SHAPE.md).

### Step 0: One-time GitHub setup

```bash
gh auth login                  # authenticate the GitHub CLI
gh auth refresh -s project     # grant the Projects v2 scope (needed for board writes)
```
`bin/doctor` reports whether `gh` is installed and authenticated.

### Step 1: Look at the Epic and its Tasks

```bash
bin/issue epic 5
```
Prints the Epic issue and the Task issues that reference it: your candidate slices.

### Step 2: Scaffold the mission from the Epic

```bash
bin/issue mission 5 weekly-digest \
  --target "$HOME/src/tracker" \
  --repo your-org/your-repo --project 4
```
This runs `bin/new-rep` and fills `MISSION.md`'s `Epic:` / `GH repo:` / `GH project:` fields,
and lists the candidate Tasks. Repo and project also resolve from `--repo`/`--project` flags,
`WORKSHOP_GH_REPO`/`WORKSHOP_GH_PROJECT` env, or the nearest `MISSION.md`, in that order.

Then drill stations 1–2 in `weekly-digest/MISSION.md`. The Task list is a *candidate* set,
not your slice plan. The slice list is yours to drill (no drilling ahead).

### Step 3: Scaffold a slice from its Task issue

```bash
bin/issue slice weekly-digest 12
```
This runs `bin/new-slice`, sets `WORKSHOP_GH_ISSUE="12"` in the slice's `.workshoprc`, and
drops the Task's Given/When/Then into the slice's `ANATOMY.md` scratch so you drill against the
issue's acceptance criteria. Finish the per-slice `.workshoprc` (target test command, watch
glob) exactly as in workflow 2.

### Step 4: Drill, then work the board with signals

Drill stations 3–7, `bin/drill-check`, then `bin/workshop <the slice from step 3>` (its
directory name is `SLICE_01_<slugified-task-title>`, printed when you scaffolded it).
Inside the session, the github-project [signals](../PAIRING_PROTOCOL.md#universal-signals)
drive the board: all **outward writes are confirmed**, never automatic:

```
issue                 # pull the active slice's Task: bin/issue show $WORKSHOP_GH_ISSUE
board "In Progress"   # move the card when you start (after you confirm → --yes)
…pair the slice green in the target repo, committing with (#12) in the subject…
pr                    # open the PR that closes #12; card moves to In Review
board "Done"          # after the PR merges
```

Under the hood every write routes `bin/issue → Workshop::Github::Gateway →
Workshop::Github::Cli → gh`. Nothing else reaches for `gh`. That single nervous system is
enforced by structure.

### The `bin/issue` reference

```
bin/issue show <n>                       # print one issue (title, labels, body)
bin/issue epic <n>                       # print an epic + the Tasks referencing it
bin/issue mission <epic-n> [name] \      # scaffold a mission from an Epic
          --target "$HOME/src/<repo>" --repo <owner/name> --project <n>
bin/issue slice <mission> <task-n>       # scaffold a slice from a Task (+ issue context)
bin/issue create "<title>" \             # create a Task issue, label it, add it to the board
          --label type:task --label phase:produce --status Todo [--body B --no-board --yes]
bin/issue board <n> "<status>" [--yes]   # move a card (Backlog/Todo/In Progress/In Review/Done/Blocked)
bin/issue pr <n> --head <branch> [--yes] # open a PR that closes the issue; card → In Review
```

`create`, `board`, and `pr` **dry-run by default** and print what they *would* do; pass
`--yes` to actually write to GitHub. In a session: propose the move, get the nod, then `--yes`.

---

## Which shape do I pick?

| If… | Use |
|-----|-----|
| you're drilling a technique in isolation | **kata** (workflow 1) |
| you're building a feature in an existing repo | **external-target** (workflow 2) |
| …and that repo tracks work as GitHub Issues/Projects | **github-project** (workflow 3) |

They're the same discipline. Start with a kata to internalize the loop, then carry it into
real work. When in doubt, read the finished
[Conway example](../examples/conway-game-of-life) end to end. It's the reference for every
artifact this guide produces.
