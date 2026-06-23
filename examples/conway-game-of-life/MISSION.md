# Mission — tick_generation

> Work level: `task`

## Station 1 — Mission

Given a Grid of live cells -> return the next Grid by applying Conway's birth/survival rules.

## Station 2 — Slice list

1. walking skeleton: blinker tick
   Risk first: Risk that the rule pipeline (count neighbours -> apply rules -> emit grid) is not wired end to end.
   Proof: RSpec: a vertical blinker becomes a horizontal blinker after one tick.
2. rule engine handles all 4 cases
   Risk first: Risk that under-population, survival, over-population, and birth are not all covered.
   Proof: RSpec table-driven specs for each rule cover all neighbour counts 0..8 for live and dead cells.
3. bounded vs. toroidal grid topology
   Risk first: Risk that the neighbour query leaks topology assumptions into the rule engine.
   Proof: RSpec: swap a BoundedGrid for a ToroidalGrid behind the same port and acceptance still passes.
