# The Rock-Drill Protocol

A repeatable, time-boxed rehearsal you run on every slice **before any code is written**. The military rock drill is a sand-table walkthrough where each operator traces their movements out loud before stepping off. This is the software analogue: trace the message flow, name the joints, declare what each object refuses to know. *Then* code.

**Total time: ~30 minutes per slice.** If it takes 90, the slice is too big.

---

## When to run it

- Before starting any non-trivial slice of work.
- After slicing a larger feature: drill slice 1 first; subsequent slices each get their own drill.
- When you feel the urge to "just start coding to see what shape it takes." That urge is the signal. Drill instead.

## When not to run it

- Pure cellular moves (rename a variable, simplify a conditional, extract a private method called from one place). These don't change the anatomy; they don't need the drill.
- Mechanical changes following a pattern already established elsewhere.

If unsure whether something is cellular or anatomical, label it up. Drill it.

---

## Drilling with the LLM

The LLM is a pair here too. Not just once code begins. Lean on it during the drill. Ask it to draw station 3 from your description, to pressure-test a refusal list, to name bypass risks you missed, to play the skeptic on your walk. A drill run with a good pair beats a drill skipped because you didn't feel ready to run it alone.

Drilling solo is the skill you're working toward, not the price of admission. Most people don't have the reps yet to trace joints and refusals cold. That's expected. It's fine. Use the pair to get the reps. The reps are how you earn the solo drill.

One rule keeps this honest: **understand everything that lands in the drill, whether you wrote it or the LLM did.** Every box. Every arrow. Every refusal. Every risk. The whole point is to put the anatomy in *your* hands before you type. An LLM that hands you a body plan you can't explain has defeated the drill, however clean the diagram looks. So interrogate it. If you can't say why a collaborator exists, what a joint lets you substitute, or what an object refuses to know, you're not done. Ask until you can, or push back until it's right.

Remember where the LLM is strong and where it isn't. It's excellent at DNA: drafting the ASCII, filling in a plausible method, listing candidates. It's mediocre at the body plan: knowing which objects should exist and what they must refuse. That judgment stays yours. Let it propose. You ratify. And you ratify only what you understand.

---

## Station 0: Discovery (before the drill)

Sometimes you don't have a mission yet. You have a problem-shaped thing: a vague ask, a ticket, a repo someone handed you. The seven stations assume you can already state the mission in one sentence. Station 0 is how you get there.

Run it with `bin/start <name>`. It scaffolds a discovery-ready mission from the problem, plus any existing repo or tracker item, and opens the workspace with the LLM in `scout` mode. In scout mode the LLM researches, investigates, and answers questions. It writes no code. Use it to read the repo, read the ticket, map what already exists, and name what you don't know. Record findings in the mission's Station 0 section and as engineering notes.

Station 0 is not timed. Discovery takes as long as the unknowns take. It is done when you can do two things: state Station 1 in one sentence, and list the slices in Station 2. The moment you can, leave scout, switch to a coding mode, and start the drill at station 1.

One rule carries over from the drill: understand everything the LLM hands you. Research you can't explain is not discovery. It's a summary you will redo the moment the design depends on it.

---

## The seven stations

| # | Station            | Time | Output                                              | Question                                          | Lands in `ANATOMY.md` as |
|---|--------------------|------|-----------------------------------------------------|---------------------------------------------------|--------------------------|
| 1 | **Mission**        | 2m   | One sentence: behavior in → behavior out            | What behavior are we designing?                   | (lives in `MISSION.md`)  |
| 2 | **Slice**          | 5m   | Ordered slice list (3–5 slices, skeleton first)     | What ships *first* with confidence?               | (lives in `MISSION.md`)  |
| 3 | **Draw**           | 5m   | ASCII anatomy: boxes, arrows, message names         | Can I draw it?                                    | `## Collaborators`       |
| 4 | **Joints**         | 3m   | For each arrow: owned/external, real default, fake  | Where can I substitute without surgery?           | `## Joints`              |
| 5 | **Refusal lists**  | 5m   | Per box: 2–4 things it does NOT know                | What does this object refuse to know?             | `## Refusals`            |
| 6 | **Walk**           | 5m   | Trace happy path message-by-message; then one fail  | Can the design run end to end?                    | `## Walk-through`        |
| 7 | **Bypass audit**   | 3m   | Plausible ways a future change adds a second path around the design | Where could the anatomy be bypassed?    | `## Bypass risks`        |

The drill operator thinks in **station numbers** (procedural: "I'm on station 4 now"). The artifact uses **semantic section names** (reader-first: "show me the Joints"). Same content, two vocabularies for two audiences.

**Then, and only then, write the acceptance test, and code begins.**

---

## Station details

### 1. Mission (2 min)

One sentence. Inputs and outputs. No implementation words.

> Good: "POST `/cart/:id/redeem` with `{code}` → `200 {result: :applied}`, all layers wired, no real logic yet."
>
> Bad: "Build the voucher redemption service using a repository pattern with policy injection."

If you can't say it in one sentence, the slice is too big. Go back to station 2.

### 2. Slice (5 min)

List 3–5 slices in shipping order. Slice 1 is always the **walking skeleton**: end-to-end through every layer with hard-coded values. Subsequent slices each add one capability.

Order by *risk*, not by *value*. The slice you're least sure about goes first. Wiring is usually the riskiest: that's why the skeleton comes first.

Don't drill ahead. Each slice gets its own drill at its own time.

### 3. Draw (5 min)

ASCII. Boxes and arrows. Message names on arrows. Return shapes noted. One screen.

```
Caller
   │ message(args)
   ▼
ServiceObject
   ├─→ Collaborator1#message(args) → return_shape
   ├─→ Collaborator2#message(args) → return_shape
   └─→ Collaborator3#message(args) → return_shape
   returns Result
```

If it doesn't fit one screen, the slice is too big.

### 4. Joints (3 min)

For every arrow in the drawing, fill a row:

| Arrow | Owned? | Real default | Test double | Notes |
|-------|--------|--------------|-------------|-------|

- **Owned?**: Yes (your code, you can change it) or No (vendor, stdlib, framework internals that you must wrap, never mock directly per §1).
- **Real default**: what production wires. Constructor default. `Processor.new` must work with no args.
- **Test double**: Real > Fake > Stub > Mock (§5). Prefer fakes living in `spec/support/fakes/`.

Time-injected globals (`clock`, `id_gen`, `logger`, `config`, `job_queue`) get rows too: they're collaborators (§6).

### 5. Refusal lists (5 min)

For every box in the drawing, write 2–4 bullets of things it explicitly does NOT know. This is where the design lives.

> `OrderClaimService` refuses to know:
>  - How Stripe stores invoices
>  - How ActiveRecord finds accounts
>  - How email is delivered
>  - How jobs are enqueued

An object with no refusal list is not designed yet; it's only named.

### 6. Walk (5 min)

Trace the happy path **out loud**, message by message. Each step references only objects and messages from your drawing.

> 1. POST arrives. Controller parses `code`.
> 2. Controller calls `Service.new(...).call(...)`.
> 3. Service calls `repo.find(code)` → returns `Thing`.
> 4. ...

If a step requires knowledge that isn't in your drawing, **you found a missing collaborator**. Add it. Redraw station 3.

Then trace **one failure mode** the same way. You don't have to enumerate all failures yet. One is enough to prove the body handles negative space.

### 7. Bypass audit (3 min)

Where could a future change bypass the anatomy? Where might a tired dev "just reach in"? Name ≥3 plausible risks with mitigations:

| Risk | Likelihood | Mitigation |
|------|-----------|------------|

Mitigations can be: enforcement (cops), structure (value object instead of AR), convention (acceptance tests use `with_adapters`), or accepted risk ("live with it, monitor"). An empty audit is dishonest.

This is the anatomy-defending-itself step. Most catastrophic failures aren't "we forgot the pattern." They're "we followed the pattern in one place and bypassed it somewhere else." Audit for second paths around the design.

---

## What ends rehearsal

The **acceptance test stub**. Written against the design from stations 3–7. Fails on real assertions (`expect(...).to ...`), not on plumbing (`NameError`, `NoMethodError on nil`).

Once the test is written, the drill is over. Code begins.

If you want a quick static audit before you start implementation, run:

```bash
bin/drill-check <slice-path>
```

It checks the presence of stations 3-7, checklist completion, refusal-list shape, bypass-audit coverage, and whether the acceptance spec still contains template placeholders. It does **not** replace running the acceptance test itself.

If you want to rehearse the drill in a browser before you export the text artifacts, run:

```bash
bin/rockdrill-visual
```

That launches the visual table for stations 1-7 as a **training framework**:

- codified role symbols (`[C]`, `[O]`, `[P]`, `[A]`, `[E]`, `[V]`, `[R]`, `[D]`)
- codified message operators (`->`, `=>`, `~>`)
- station-by-station coaching prompts
- derived checklist feedback
- copyable exports for `MISSION.md`, `ANATOMY.md`, and `spec/acceptance_spec.rb`

The point is not freeform note-taking. The point is to practice the rock drill
in a shared language that builds the artifacts directly.

---

## Eight checks before the drill is "done"

1. **One-screen test**: anatomy diagram fits one terminal screen.
2. **One-sentence test**: mission is one sentence, behavior-in/behavior-out.
3. **Refusal-list completeness**: every box has ≥2 refusal items.
4. **Joint completeness**: every arrow has a real default AND a test double.
5. **Walk test**: every walk step uses only objects/messages from the drawing.
6. **Red-shape test**: acceptance test fails on assertions, not plumbing.
7. **Bypass-audit honesty**: ≥3 named risks with mitigations or accepted-risk labels.
8. **Timer test**: total elapsed ~30 min.

If any check fails, you skipped a station. Go back.

---

## What the drill is *not*

- It is **not** a design document. It's a rehearsal. Rough, fast, time-boxed.
- It is **not** a one-time exercise. It's a habit. Every slice. Every time.
- It is **not** a substitute for coding. It's the thing you do *before* coding so the coding goes fast and clean.

The point of the drill is not to produce perfect drills. It is to make anatomical thinking *automatic*: so that by the time you're typing, the joints, refusal lists, and message flow are already in your hands. The drill is the practice; production code is the performance.
