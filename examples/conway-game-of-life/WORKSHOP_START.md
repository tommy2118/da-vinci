# Workshop Start — Conway's Game of Life

> Repo slug: `conway-game-of-life`
> Workshop slice dir: `conway-game-of-life/SLICE_01_walking_skeleton`
> First slice: `01 walking skeleton`

## Bootstrap intent

Given a Grid of live cells -> return the next Grid by applying Conway's birth/survival rules.

## Create these directories first

- `conway-game-of-life`
- `conway-game-of-life/SLICE_01_walking_skeleton`
- `conway-game-of-life/SLICE_01_walking_skeleton/spec`

## Create these starter files

- `conway-game-of-life/MISSION.md`
- `conway-game-of-life/SLICE_01_walking_skeleton/ANATOMY.md`
- `conway-game-of-life/SLICE_01_walking_skeleton/spec/acceptance_spec.rb`
- `conway-game-of-life/WORKSHOP_START.md`

## Suggested startup order

1. Download the starter bundle so you have the drill JSON export.
2. Run `npm run bootstrap -- /path/to/conway-game-of-life-rock-drill.json --launch-tmux`.
3. If you skip the CLI, create `conway-game-of-life` and `conway-game-of-life/SLICE_01_walking_skeleton` manually, then write the files listed below.
4. Run `../bin/drill-check conway-game-of-life/SLICE_01_walking_skeleton`.
5. Make the acceptance file fail honestly before adding implementation.
6. Build only the walking skeleton named in this drill.

## Slice order

1. walking skeleton: blinker tick — RSpec: a vertical blinker becomes a horizontal blinker after one tick.
2. rule engine handles all 4 cases — RSpec table-driven specs for each rule cover all neighbour counts 0..8 for live and dead cells.
3. bounded vs. toroidal grid topology — RSpec: swap a BoundedGrid for a ToroidalGrid behind the same port and acceptance still passes.

## Walking skeleton proof

1. ? [C] TickRequester hands a blinker Grid (3 vertical live cells) to [O] GameOfLife.
2. ? [O] GameOfLife asks [P] NeighbourQuery for live-neighbour counts of every relevant cell.
3. ? [A] BoundedGridAdapter answers each count using the real Grid; off-grid cells contribute 0.
4. ? [O] GameOfLife emits [R] NextGrid containing the horizontal blinker (3 horizontal live cells).

## Risk watchlist

- Caller skips [O] GameOfLife and mutates Grid directly to 'fix a bug'. -> Make Grid an immutable frozen value object; expose only Grid.with(live_cells:).
- [O] GameOfLife inlines neighbour counting instead of going through [P] NeighbourQuery, leaking bounded-grid assumptions. -> Acceptance test swaps in a ToroidalGridAdapter and asserts a glider wraps; failure proves the seam is honest.
- Rendering / IO sneaks into [O] GameOfLife (printing the grid each tick) and pins it to a console. -> Keep [O] GameOfLife pure: it returns [R] NextGrid; rendering lives in a separate Caller-side renderer.

## Acceptance artifact

`conway-game-of-life/SLICE_01_walking_skeleton/spec/acceptance_spec.rb`

## Workshop commands

```bash
npm run bootstrap -- /path/to/conway-game-of-life-rock-drill.json --launch-tmux
../bin/drill-check conway-game-of-life/SLICE_01_walking_skeleton
```

## Manual fallback

```bash
mkdir -p conway-game-of-life/SLICE_01_walking_skeleton/spec
$EDITOR conway-game-of-life/MISSION.md conway-game-of-life/SLICE_01_walking_skeleton/ANATOMY.md conway-game-of-life/SLICE_01_walking_skeleton/spec/acceptance_spec.rb
../bin/workshop conway-game-of-life/SLICE_01_walking_skeleton
```

## Bootstrap notes

Pure functional core. No I/O in the core; rendering and timing live behind ports. Ruby + RSpec.
