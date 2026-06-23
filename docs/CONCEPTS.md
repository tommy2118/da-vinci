# Concepts — the Da Vinci mental model

Read this once. It defines every word the rest of the docs use. When you want to *do*
something, jump to [WORKFLOWS.md](WORKFLOWS.md) for the three end-to-end walkthroughs.

---

## What Da Vinci is for

Da Vinci is a **practice space** for two disciplines that are hard to learn by reading:

- **Anatomy-first object design** — deciding what objects exist, what messages move between
  them, where the joints are, and what each object *refuses to know*, **before** writing the
  cellular detail inside them.
- **GOOS outside-in TDD** — growing software guided by tests, from a failing acceptance test
  on the outside to fast unit tests on the inside, with the hardened §1–§6 testing rules that
  keep mocks honest.

You practice by pairing with an AI (Claude) under an explicit, declared **mode** that
controls who writes what. The point is the *form* of the practice — the reps — not the
output. A finished kata is a side effect of a good rep.

The discipline itself — the anatomy frame, the §1–§6 rules, Sandi's rules, the registry seam —
is defined in **[DISCIPLINE.md](DISCIPLINE.md)**; this guide and the walkthroughs reference it
by number and name. (Your global `~/.claude/CLAUDE.md`, if you keep one, applies on top.) The
workshop is the *structure* Da Vinci puts around that discipline: how you scope work, rehearse
a design, and run the loop.

---

## The unit hierarchy: mission → slice → drill → code

```
Mission        a body of work (days)        -> MISSION.md   (stations 1–2)
  └ Slice      a 1–2 day shippable unit     -> a SLICE_NN_* directory
      └ Drill  a ~30-min design rehearsal   -> ANATOMY.md   (stations 3–7)
          └ Code  the implementation         -> production code + tests
```

### Mission

A body of work that decomposes into slices. Its `MISSION.md` holds the first two rock-drill
stations: a **one-sentence mission statement** (behavior in → behavior out) and an **ordered
slice list** (3–5 slices, ordered by *risk*). You scaffold one with `bin/new-rep <name>`.

### Slice

A unit of work shippable on its own, ~1–2 days. **Slice 1 of every mission is always the
walking skeleton** — the smallest thing that exercises every layer end to end with hard-coded
values, to prove the stack is wired before real logic lands on top. Each later slice adds one
capability. You scaffold the next slice with `bin/new-slice <mission> <name>`; it creates a
`SLICE_NN_<name>/` directory with an `ANATOMY.md`, a `.workshoprc`, and an acceptance-spec
stub.

### Drill (the rock drill)

Before any code, you **rehearse the slice's design** in a ~30-minute, seven-station drill.
You draw the objects and messages, name the joints (where you can substitute), write each
object's refusal list, walk the happy path plus one failure out loud, and audit for ways a
future change could bypass the design. The output is `ANATOMY.md`. The drill *ends* when you
write the acceptance-test stub. See [ROCK_DRILL_PROTOCOL.md](../ROCK_DRILL_PROTOCOL.md) for
all seven stations; `bin/drill-check <slice>` statically audits a drilled `ANATOMY.md`.

> Why rehearse first? Anatomical mistakes (wrong objects, buried joints, an object that knows
> too much) are expensive to fix once cellular code is piled on top. The drill makes the
> anatomy visible and cheap to change while it's still text.

### Code

Only now do you write production code, driven by the two loops below, under the active
pairing mode.

---

## The two loops (outside-in)

Outside-in TDD runs two loops at once:

- **Outer loop (acceptance):** one failing acceptance test per slice, against the **real**
  stack — real DB, real router, real wiring; only the true external edges (Stripe, email, S3)
  are substituted. It stays red until the slice actually works. It catches mocks that lie.
- **Inner loop (unit):** many fast unit tests, one per object, driving each object's design.
  Mocks here are fine *because* the outer loop catches their lies.

The walking skeleton's acceptance test is the first outer-loop test. It must fail on a **real
assertion** (a wrong value), not on plumbing (a `NameError`) — that "honest red" is the proof
the stack is wired.

---

## ANATOMY.md — the drill artifact

Each slice's `ANATOMY.md` is the written output of stations 3–7. Its sections:

- **Collaborators** — the ASCII drawing: boxes (objects), arrows (messages), return shapes.
- **Joints** — per arrow: owned or external, the real production default, the test double.
- **Refusals** — per box: 2–4 things it explicitly does NOT know. *This is where the design
  lives.*
- **Walk-through** — the happy path traced message-by-message, plus one failure path.
- **Bypass risks** — ≥3 plausible ways a future change could route around the design, with
  mitigations.
- **Verification checklist** — the eight "is the drill done?" checks.

The example at
[`examples/conway-game-of-life/SLICE_01_walking_skeleton/ANATOMY.md`](../examples/conway-game-of-life/SLICE_01_walking_skeleton/ANATOMY.md)
is a complete, drilled instance — read it alongside the protocol.

---

## Pairing modes — who writes what

The AI's behavior is governed by a **mode**, declared as `WORKSHOP_MODE` in `.workshoprc`.
You switch mid-session by typing `mode <name>`. The five modes
([full definitions](../PAIRING_PROTOCOL.md#modes)):

| Mode | Who writes production code | Use it to… |
|------|----------------------------|------------|
| **navigator** | You type every keystroke; Claude prescribes precise moves | learn a pattern from scratch; build the typing-and-judgment muscle |
| **coach** | You; Claude never writes code, only asks Socratic questions and names smells | sharpen judgment when you can already write the code |
| **ping-pong** | Alternating: you write a red test → Claude writes the dumb pass → you refactor | drill Beck's Red→Green→Refactor rhythm on small katas |
| **constraint** | You, freely; Claude declares constraints up front and reviews on demand | stress-test a specific habit (Sandi's rules, §1–§6, "no nil") |
| **true-pair** | Mostly you; Claude takes bounded hand-offs (`take this`) and carries manual testing | real work where you drive but want to offload chunks |

## Signals — how you talk to the AI

Short commands you type into the AI pane, working in every mode. The full table is in
[PAIRING_PROTOCOL.md](../PAIRING_PROTOCOL.md#universal-signals). The ones you'll use most:

| Signal | Meaning |
|--------|---------|
| `diff` | show + review uncommitted state per the active mode |
| `smell` | full review via the [six-question rubric](DISCIPLINE.md#reviewing-with-this-discipline) (anatomy + §1–§6 + Sandi) |
| `next` | next move (navigator) / next question (coach) |
| `run` | run the test command (`WORKSHOP_TEST_CMD`) and report |
| `green` / `red <desc>` | tests pass / help me read this failure |
| `drill` | rehearse a slice or sub-problem via the rock drill |
| `mode <name>` | switch modes |
| `note` | capture a durable engineering note |
| `where` / `pause` | where are we / remember where we are |
| `issue` / `board <status>` / `pr` | *github-project missions:* read the Task, move its card, open its PR |

---

## The three mission shapes

Every mission is one of three shapes. They share everything above; they differ only in
*where the code lands* and *where the unit of work is tracked*. Each has a full walkthrough in
[WORKFLOWS.md](WORKFLOWS.md).

1. **Self-contained kata** — the slice *is* a standalone Ruby project; code and specs live in
   the slice directory. Best for drilling a technique in isolation. Example:
   `examples/conway-game-of-life`.
2. **External-target mission** — you drill in the workshop, but the code and the real
   acceptance test land in **another repo** (e.g. a real Rails app). The slice `.workshoprc`
   points the runner at that target. This is how you do real work on an existing codebase.
3. **GitHub-project mission** — an external-target mission whose **unit of work lives in
   GitHub**: an Epic issue is the mission, Task issues are slices, tracked on a Projects v2
   board. `bin/issue` drives it. Best for a side project (or any repo) managed with GitHub
   Issues + Projects.

---

## Framework vs. content: the two-repo model

The workshop separates two things that change for different reasons:

- **The framework** (this repo): the protocols, the `bin/` tooling, templates, and the
  bundled `examples/`. Shared, editor-agnostic, the same for everyone.
- **Your content**: your missions, slices, and engineering notes. Personal to you.

`WORKSHOP_CONTENT_DIR` is the seam. Unset, it defaults to the framework root — so everything
lives in one checkout, which is fine to start. Point it at a separate repo (in your gitignored
`.workshoprc.local`) and `bin/new-rep`, `bin/new-slice`, `bin/note`, `bin/issue`, and
`bin/drill-check` all read and write *there* instead, while the bundled `examples/` still run
from the framework. That keeps your practice content out of a shared framework clone.

```bash
# .workshoprc.local  (gitignored; copy from .workshoprc.local.example)
export WORKSHOP_CONTENT_DIR="$HOME/src/workshop-personal"
```

---

## Launchers — your editor, your terminal

`bin/workshop <slice>` opens your workbench. *How* it arranges things is the **launcher**,
chosen by `WORKSHOP_LAUNCHER`:

| Launcher | What it does |
|----------|--------------|
| `manual` (default) | prints the three commands (open folder, run watcher, run AI) — works in **any** editor, no deps |
| `tmux` | a 3-pane tmux session: editor, watcher, AI |
| `vscode` / `cursor` | opens the folder(s), wires a watch task, prints the pair commands |
| `emacs` | opens the folder(s), prints the watch + pair commands |

All three things a slice needs are the same regardless of launcher: an **editor**, a
**watcher** (`bin/watch`, which re-runs `WORKSHOP_TEST_CMD` on save), and an **AI pair**
(`WORKSHOP_AI_CMD`, default `claude`). Set your preference in `.workshoprc.local`.

---

## Engineering notes

Durable knowledge you uncover — a finding, decision, gotcha, reference, open question, or
lesson — becomes a **note** via `bin/note`, not an inline comment or a bloated `MISSION.md`
cell. Notes are one frontmatter file each under `notes/` (in your content dir), discoverable
via `bin/note find` and a generated `notes/INDEX.md`. In a session, the `note` signal drafts
one from the current context. This is how the corpus accumulates and guides later work:
when you start a mission or touch a target, you consult the notes first.

---

## How a session actually runs

1. `bin/workshop <slice>` opens the workbench (editor + watcher + AI), with the AI's cwd set
   to the slice so it auto-loads the workshop's `CLAUDE.md` bootstrap.
2. The AI reads the protocols and the slice's `ANATOMY.md`, then states the active **mode**,
   the **signals** in play, and **where you left off** — and waits.
3. You drive with **signals**. The watcher gives you a red/green loop on every save. You
   commit per slice.

That's the whole machine. The walkthroughs put it in motion.
