# Slice 01 — Walking Skeleton: Anatomy

> Mission: `tick_generation` (see `../MISSION.md`).
> Work level: `task`.
> Drilled per `ROCK_DRILL_PROTOCOL.md`, stations 3–7.

**Scope reminder**: Advance one generation for a small hard-coded blinker; prove the rule pipeline is wired end to end.

---

## Codified grammar

- [C] Caller — entry point
- [O] Core object — decision owner
- [P] Port — owned seam
- [A] Adapter — wrapper
- [V] Value object — data shape
- [R] Result — outcome contract
- -> owned call
- => handoff across a seam
- ~> publication / notification
- returns outcome shape
- ! refusal bullet
- ? proof step

## Collaborators

```
[C] TickRequester :: Entry point: hands a Grid in, receives NextGrid out.
[O] GameOfLife :: Applies Conway's rules via the neighbour port.
[P] NeighbourQuery :: Counts live neighbours of cell (x,y) in a Grid.
[A] BoundedGridAdapter :: NeighbourQuery for a finite grid; off-grid = dead.
[V] Grid :: Immutable live-cell set with width and height.
[R] NextGrid :: Grid emitted by one tick; same shape, one gen forward.
[C] TickRequester -> [O] GameOfLife#tick(grid:) returns [R] NextGrid
[O] GameOfLife -> [A] BoundedGridAdapter.new(grid:) returns a [P] NeighbourQuery (factory: one instance per tick)
[O] GameOfLife -> [P] NeighbourQuery#count_live_neighbours(x:, y:) returns Integer
```

## Joints

| Arrow | Owned? | Real default | Test double | Notes |
|-------|--------|--------------|-------------|-------|
| [C] TickRequester -> [O] GameOfLife#tick(grid:) | yes | GameOfLife.new | FakeGameOfLife | Pure function: same input grid always yields same next grid; no side effects. |
| [O] GameOfLife -> [A] BoundedGridAdapter.new(grid:) | dependency | factory: `BoundedGridAdapter` (the class); per tick: `BoundedGridAdapter.new(grid: grid)` | anonymous `double("NeighbourQuery factory")` for single-use interaction tests; promote to named fake when reused 5+ times (§5) | GameOfLife is injected with the *class* and constructs one adapter per `tick`, wrapping that tick's input grid. |
| [O] GameOfLife -> [P] NeighbourQuery#count_live_neighbours(x:, y:) | dependency | the per-tick adapter from the row above | anonymous `double("NeighbourQuery")` for single-use; promote to named fake when reused | Returns count in 0..8; never raises for in-bounds or out-of-bounds coords (out-of-bounds counted as dead). |

## Refusals

### [O] GameOfLife
- Does NOT know how cells are stored (array, set, sparse map).
- Does NOT know the grid topology (bounded, toroidal, infinite).

### [A] BoundedGridAdapter
- Does NOT know Conway's birth/survival rules.
- Does NOT mutate or own the Grid; it only answers neighbour counts.

### [C] TickRequester
- Does NOT know Conway's rules or how to count neighbours.
- Does NOT mutate the Grid; it only hands a Grid in and receives [R] NextGrid.

### [P] NeighbourQuery
- Does NOT know Conway's birth/survival rules.
- Does NOT decide a cell's next state; it only answers a count.

### [V] Grid
- Does NOT know Conway's rules; it just holds live-cell coordinates and dimensions.
- Does NOT mutate; any change returns a new Grid.

### [R] NextGrid
- Does NOT know how it was computed; it only carries the resulting Grid state.
- Does NOT know about rendering or display; it is a pure data value.

## Walk-through

### Happy path
1. ? [C] TickRequester hands a blinker Grid (3 vertical live cells) to [O] GameOfLife.
2. ? [O] GameOfLife asks [P] NeighbourQuery for live-neighbour counts of every relevant cell.
3. ? [A] BoundedGridAdapter answers each count using the real Grid; off-grid cells contribute 0.
4. ? [O] GameOfLife emits [R] NextGrid containing the horizontal blinker (3 horizontal live cells).

### One failure path
1. ? [C] TickRequester hands a Grid with width=0 or height=0 to [O] GameOfLife.
2. ? [O] GameOfLife raises ArgumentError('grid must have positive dimensions'); no [P] NeighbourQuery call is made.

## Bypass risks

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Caller skips [O] GameOfLife and mutates Grid directly to 'fix a bug'. | medium | Make Grid an immutable frozen value object; expose only Grid.with(live_cells:). |
| [O] GameOfLife inlines neighbour counting instead of going through [P] NeighbourQuery, leaking bounded-grid assumptions. | high | Acceptance test swaps in a ToroidalGridAdapter and asserts a glider wraps; failure proves the seam is honest. |
| Rendering / IO sneaks into [O] GameOfLife (printing the grid each tick) and pins it to a console. | low | Keep [O] GameOfLife pure: it returns [R] NextGrid; rendering lives in a separate Caller-side renderer. |

---

## Verification checklist

- [x] One-screen test — Draw notation fits on one screen: 8 lines, widest line 82 chars.
- [x] One-sentence test — Mission statement and scope reminder both read as one sentence.
- [x] Refusal-list completeness — 6/6 named roles have 2+ refusal bullets.
- [x] Joint completeness — 2/2 messages name the seam, real default, and test double.
- [x] Walk test — Happy path: 4 steps. Failure path: 2 steps. Prefix proof lines with [symbol] tags.
- [x] Red-shape test — Acceptance assertion includes expect(...) and no template placeholder.
- [x] Bypass-audit honesty — 3 complete risks captured; target at least 3.
- [x] Timer test — Timer check marked.
