# Slice 03 — topology

> **Scope**: Introduce `[A] ToroidalGridAdapter` implementing the existing `[P] NeighbourQuery` port and ship a new acceptance test using it; no edits to `[O] GameOfLife` or any other existing object, and no topology-switching infrastructure (factories, value objects, config) beyond the constructor-injectable adapter that already exists.

Mission: `conway-game-of-life` · Drilled via [rock drill](../../ROCK_DRILL_PROTOCOL.md) stations 3-7.

---

## Collaborators

> **How to think**: Start at the caller. What enters the system, what receives it, what message travels where? Follow the messages outward until you hit a leaf. Each box gets a role symbol; each arrow names a message and its return shape.
>
> **Heuristic**: *Can I draw it?* If you can, the anatomy is visible. If arrows go everywhere, it's tangled. If one box owns every arrow, you found a god object. Cap at ~5-7 boxes — more and the slice is too big.
>
> **Watch for**: arrows you can't name, boxes you can't justify, vendor SDKs sitting next to your own objects (wrap them — §1).

```
[C] TickRequester       :: Entry: hands a Grid in, receives NextGrid out.
[O] GameOfLife          :: Orchestrates: iterate cells, ask rule, build NextGrid.
[P] NeighbourQuery      :: Counts live neighbours of cell (x,y) in a Grid.
[A] BoundedGridAdapter  :: NeighbourQuery for a finite grid; off-grid = dead.
[A] ToroidalGridAdapter :: NeighbourQuery for a torus topology; off-grid coords wrap via modulo.
[V] Grid                :: Immutable live-cell set with width/height; answers cell state at coords.
[R] NextGrid            :: Grid emitted by one tick; same shape, one gen forward.
[O] ConwayRule          :: Pure rule: given (state, neighbour count) -> next state.
[V] CellState           :: Alive | Dead — value type for cell states (two singletons).

[C] TickRequester -> [O] GameOfLife#tick(grid:)                            returns [R] NextGrid
[O] GameOfLife    -> @neighbour_query_factory.new(grid:)                   returns a [P] NeighbourQuery (one per tick)

    where @neighbour_query_factory is one of:
      [A] BoundedGridAdapter   (slice 2 default; off-grid = dead)
      [A] ToroidalGridAdapter  (slice 3 default for new acceptance test; off-grid wraps via modulo)

[O] GameOfLife    -> [P] NeighbourQuery#count_live_neighbours(x:, y:)      returns Integer
[O] GameOfLife    -> [V] Grid#cell_at(x:, y:)                              returns [V] CellState
[O] GameOfLife    -> [O] ConwayRule#next_state(state:, neighbour_count:)   returns [V] CellState
```

**Legend**: `[C]` caller · `[O]` core object · `[P]` port · `[A]` adapter · `[V]` value · `[R]` result · `->` owned call · `=>` cross-seam handoff · `~>` publication · `?` proof step

## Joints

> **How to think**: A joint is any place substitution matters — the seams between owned objects, and the boundary where you wrap external types. For each arrow ask: *what would I have to replace to test this in isolation?*
>
> **Heuristic**: Real > Fake > Stub > Mock (§5). Owned > External (§1). Every collaborator should have a real default in the constructor (§4). If a test would need `allow_any_instance_of` or `stub_const`, the joint should have been injected.
>
> **Watch for**: arrows whose test double is "I'll just mock the class directly" — that's a missing injection. Time, randomness, env, logger, jobs are joints too (§6) — not language features.

| Arrow | Real default | Test double |
|-------|--------------|-------------|
| `[C] TickRequester -> [O] GameOfLife#tick(grid:)` | `GameOfLife.new` (all kwargs default; `neighbour_query_factory:` overridable per slice 3) | none — caller is the spec |
| `[O] GameOfLife -> @neighbour_query_factory.new(grid:)` | The injected factory class. Slice 2 default: `BoundedGridAdapter`. Slice 3 acceptance test: `ToroidalGridAdapter`. Per tick: `<Adapter>.new(grid: grid)`. | anonymous `double("NeighbourQuery factory")` for single-use; promote to `spec/support/fakes/fake_neighbour_query_factory.rb` if reused 5+ times (§5) |
| `[O] GameOfLife -> [P] NeighbourQuery#count_live_neighbours(x:, y:)` | per-tick adapter from row above (Bounded or Toroidal) | `FakeNeighbourQuery` (named, in `spec/support/fakes/`) — reused across slice 2 and slice 3 unit specs (§5) |
| `[O] GameOfLife -> [V] Grid#cell_at(x:, y:)` | the input grid (no double) | **real Grid** — value object is frozen and cheap; per §5 prefer real over fake when fast and owned |
| `[O] GameOfLife -> [O] ConwayRule#next_state(state:, neighbour_count:)` | `ConwayRule.new` | **real ConwayRule** for integration specs (pure & fast); anonymous `double("ConwayRule")` only when isolating GameOfLife from rule semantics |

Notes per arrow:
- `tick(grid:)`: Pure function — same input grid always yields same NextGrid; no side effects.
- `@neighbour_query_factory.new(grid:)`: One adapter per tick, wrapping that tick's input grid. **The injected factory determines topology** — that's the substitution point this slice exercises. Both `BoundedGridAdapter` and `ToroidalGridAdapter` honor the same `NeighbourQuery` port contract.
- `count_live_neighbours(x:, y:)`: Returns 0..8; never raises (in-bounds). **Both adapters honor this contract** — a shared contract spec (§3) verifies both conform.
- `cell_at(x:, y:)`: Returns `CellState::ALIVE` or `CellState::DEAD`. **Raises on out-of-bounds coords** — off-grid handling is the adapter's job (`BoundedGridAdapter` skips off-grid neighbours; `ToroidalGridAdapter` wraps them so they're always in-bounds when passed to Grid).
- `next_state(state:, neighbour_count:)`: Pure function. Returns `CellState`. Topology-blind by design.

## Refusals

> **How to think**: For each box, ask *what would surprise me if this object knew?* That's the refusal. Refusal is design. An object with no refusal list is not designed yet — it's only named.
>
> **Heuristic**: 2-4 refusals per box. Bullets phrased "Does NOT know X" — the negative framing is doctrinal. Each bullet should describe responsibility owned by *another* object in your diagram, or out of scope entirely.
>
> **Watch for**: refusals that describe implementation details ("doesn't use a Hash"). Those are cellular, not anatomical. Refusals are about what the object's role excludes.

### `[C] TickRequester`
- Does NOT know Conway's rules.
- Does NOT mutate the Grid.

### `[O] GameOfLife`
- Does NOT know how cells are stored (delegates to Grid).
- Does NOT know the grid topology (bounded vs toroidal — delegates to NeighbourQuery via the adapter).
- Does NOT know the *content* of Conway's rules (which counts → alive/dead) — delegates to ConwayRule.
- Does NOT decide off-grid neighbour semantics — that's the configured NeighbourQuery adapter's job.

### `[P] NeighbourQuery`
- Does NOT know Conway's rules.
- Does NOT decide a cell's next state.
- Does NOT mutate the Grid.

### `[A] BoundedGridAdapter`
- Does NOT know Conway's rules.
- Does NOT mutate or own the Grid.
- Does NOT decide a cell's next state.

### `[A] ToroidalGridAdapter`
- Does NOT know Conway's rules.
- Does NOT mutate or own the Grid.
- Does NOT decide a cell's next state.
- Does NOT raise on neighbour coords outside the Grid bounds — wraps them via modulo before delegating to `Grid#cell_at`.
- Does NOT distinguish "edge" from "interior" cells — topology is uniform; every cell has exactly 8 neighbours.
- Does NOT expose its wrapping mechanism (modulo) to callers — `count_live_neighbours` returns the count and nothing else.

### `[V] Grid`
- Does NOT know Conway's rules.
- Does NOT mutate; any change returns a new Grid.
- Does NOT answer about out-of-bounds coords — raises instead. Off-grid semantics belong to the NeighbourQuery adapter (Bounded skips; Toroidal wraps).

### `[R] NextGrid`
- Does NOT know how it was computed.
- Does NOT know about rendering or display.

### `[O] ConwayRule`
- Does NOT know about Grid structure, storage, or coordinates — only takes (state, count) and returns next state.
- Does NOT know about iteration — it's a pure per-cell function.
- Does NOT know about topology (bounded vs toroidal) — works for any integer neighbour count.
- Does NOT mutate its inputs.

### `[V] CellState`
- Does NOT know Conway's rules.
- Does NOT know about Grid coordinates or neighbour counts.
- Does NOT mutate (singletons are frozen).
- Does NOT have intermediate states — only Alive and Dead.

## Walk-through

> **How to think**: Trace the happy path out loud, one message per step. Each step uses only the boxes and arrows from `Collaborators`. If a step needs something you didn't draw, *you found a missing collaborator* — go back and add it before continuing.
>
> **Heuristic**: Each numbered step = one message send. Use exact names from the diagram. Mark each step with `?` to denote "the acceptance test will prove this step."
>
> **Watch for**: steps that mention concepts not in the diagram. The walk is the design diagnosing itself — listen to it.

### Happy path
1. ? [C] TickRequester hands a 3×3 Grid with the **four-corners pattern** (live cells `(0,0), (0,2), (2,0), (2,2)`) to [O] GameOfLife, with `neighbour_query_factory: ToroidalGridAdapter` injected at construction.
2. ? [O] GameOfLife constructs [A] ToroidalGridAdapter.new(grid: grid) once for this tick.
3. ? [O] GameOfLife iterates each cell `(x, y)` for `x in 0...width`, `y in 0...height`.
4. ? For each cell, [O] GameOfLife asks [V] Grid#cell_at(x:, y:) → [V] CellState (ALIVE or DEAD).
5. ? For each cell, [O] GameOfLife asks [P] NeighbourQuery#count_live_neighbours(x:, y:) → Integer (0..8). [A] ToroidalGridAdapter wraps each neighbour offset via `nx % width` and `ny % height` before delegating to `Grid#cell_at` — so every cell has exactly 8 in-bounds neighbours.
6. ? For each cell, [O] GameOfLife asks [O] ConwayRule#next_state(state:, neighbour_count:) → [V] CellState.
7. ? [O] GameOfLife collects `(x, y)` coords where `next_state == CellState::ALIVE`.
8. ? [O] GameOfLife emits [R] NextGrid via `Grid.with(width: 3, height: 3, live_cells: [(0,0), (0,2), (2,0), (2,2)])` — the **same** four-corners pattern, stable on torus. (On bounded, this same input would yield an empty grid; that contrast is the substitution proof.)

### Failure path
1. ? [C] TickRequester hands a Grid with `width = 0` or `height = 0` to [O] GameOfLife (via test doubles — real `Grid.with` validates upstream and raises before construction).
2. ? [O] GameOfLife raises `ArgumentError("grid must have positive dimensions")` immediately; no adapter construction, no rule calls, no [V] Grid#cell_at calls, no NextGrid emitted. **Defense-in-depth**: real Grid construction raises first; GameOfLife's check is the secondary catch — and it also prevents modulo-by-zero from ever being reachable inside ToroidalGridAdapter.

## Bypass risks

> **How to think**: Where could a future change route around this design? Where might a tired dev "just reach in"? The catastrophic failure mode isn't "we forgot the pattern" — it's "we followed the pattern in one place and bypassed it somewhere else." The anatomy growing a second nervous system.
>
> **Heuristic**: Minimum 3 named risks, each with a mitigation. Mitigations come in flavors: *enforcement* (a cop), *structure* (a value object that can't be misused), *convention* (helper method, acceptance test pattern), or *accepted* ("live with it, monitor"). An empty audit is dishonest.
>
> **Watch for**: vague mitigations ("be careful"). Risks that don't describe *bypassing* — those are general project risks. This section is specifically about second paths around the design.

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| [O] GameOfLife re-implements neighbour counting inline (the slice 2 anatomical risk that slice 3 is meant to disprove, but does not eliminate). | high | Slice 3's acceptance test is the **ongoing proof**: with `ToroidalGridAdapter` injected, the four-corners pattern stays stable. If GameOfLife ever inlines bounded-grid logic, the toroidal acceptance test fails immediately. |
| [A] ToroidalGridAdapter duplicates Conway rule logic (e.g., `if count == 3 ...` leaks into the adapter). | medium | All Conway integer literals (0, 1, 2, 3) live only in `ConwayRule`. ToroidalGridAdapter computes counts (0..8) via wrapping; rule application stays in ConwayRule. ConwayRule unit specs are the only place naming specific counts. |
| Modulo arithmetic (`% width`, `% height`) leaks outside [A] ToroidalGridAdapter — e.g., into [O] GameOfLife or [V] Grid as a "small helper". | medium | All coordinate wrapping happens inside ToroidalGridAdapter. GameOfLife passes raw `(x, y)` from its iteration; Grid raises on out-of-bounds (no wrapping). The adapter is the only object that knows about modulo. |
| Adapter inheritance: `ToroidalGridAdapter < BoundedGridAdapter` (or vice versa) to "reuse" the neighbour-iteration scaffold. | medium | Per CLAUDE.md — **duck typing over inheritance**. Each adapter is a standalone class honoring the same port protocol. Code reuse, if needed, comes from extracted module or value object — not parent class. Reviewed at PR time. |
| No shared **contract spec** for the [P] NeighbourQuery port — both adapters implement it but only acceptance tests verify their consistency. | high | Add `shared_examples "a NeighbourQuery"` (per CLAUDE.md §3). Both `BoundedGridAdapter` and `ToroidalGridAdapter` include it. Each adapter's contract spec verifies it honors the same port contract (returns 0..8, behavior at boundaries, never raises in-bounds). |

---

## Verification checklist

> *Drill instrument — fold mentally once green. The rest of this document is the artifact a reader picks up cold; this section is for the drill operator.*

- [x] One-screen test — anatomy diagram fits one terminal screen (~17 lines including legend, widest ~110 chars).
- [x] One-sentence test — scope reminder reads as a single statement (semicolon-joined clauses).
- [x] Refusal-list completeness — 9/9 boxes have 2+ refusal bullets (`[A] ToroidalGridAdapter` has 6).
- [x] Joint completeness — 5/5 arrows have real default + test double + notes; the `@neighbour_query_factory.new(grid:)` row names both adapters as alternative real defaults.
- [x] Walk test — happy path (8 steps) and failure path (2 steps) reference only objects/messages in Collaborators.
- [x] Red-shape test — acceptance spec uses `expect(...).to eq(...)`; well-formed. Initial red against the empty slice 3 `lib/` will be plumbing (`LoadError` on `toroidal_grid_adapter`); assertion-red appears once the file is scaffolded.
- [x] Bypass-audit honesty — 5 named risks, each with a concrete mitigation (test-driven, structural, or convention-based; no vague hand-waving).
- [x] Timer test — drill stayed within budget (interactive drafting on mobile).

When all eight pass, write the acceptance test stub; that ends the drill.

---

## Scratch (live notes during the slice)

<!-- Append "we are here" notes here when pausing mid-slice. -->
