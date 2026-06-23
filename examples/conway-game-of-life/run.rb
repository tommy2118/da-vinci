#!/usr/bin/env ruby
# frozen_string_literal: true

# Demo runner for Conway's Game of Life.
# Loads slice 3 (the topology-substitution slice; most complete version).
# Runs a chosen pattern on a chosen topology, animating with screen-clear.
#
# Run with: ruby conway-game-of-life/run.rb  (or ./conway-game-of-life/run.rb if executable)
# Stop with: Ctrl-C

$LOAD_PATH.unshift(File.expand_path("SLICE_03_topology/lib", __dir__))

require "game_of_life"
require "grid"
require "cell_state"
require "bounded_grid_adapter"
require "toroidal_grid_adapter"
require "hexagonal_grid_adapter"

# === Knobs (edit these) ===
TOPOLOGY = :toroidal   # :bounded | :toroidal | :hexagonal
PATTERN  = :glider     # :blinker | :glider | :beacon
WIDTH = 20
HEIGHT = 20
TICK_DELAY = 0.1       # seconds between generations

ALIVE_CHAR = "█"
DEAD_CHAR = "·"

# === Patterns (top-left coordinates of the seed pattern) ===
PATTERNS = {
  blinker: [[0, 1], [1, 1], [2, 1]].freeze,
  glider:  [[1, 0], [2, 1], [0, 2], [1, 2], [2, 2]].freeze,
  beacon:  [[0, 0], [1, 0], [0, 1], [3, 2], [2, 3], [3, 3]].freeze,
}.freeze

# === Adapters (one class per topology — all honour the NeighbourQuery port) ===
ADAPTERS = {
  bounded:   BoundedGridAdapter,
  toroidal:  ToroidalGridAdapter,
  hexagonal: HexagonalGridAdapter,
}.freeze

adapter_class = ADAPTERS.fetch(TOPOLOGY)
pattern_cells = PATTERNS.fetch(PATTERN)

def render(grid, generation, topology, pattern_name)
  print "\e[H\e[2J" # ANSI: cursor home + clear screen
  puts "Conway's Game of Life — #{pattern_name.to_s.capitalize} on #{topology} #{grid.width}×#{grid.height}"
  puts "Generation: #{generation}  (Ctrl-C to stop)"
  puts
  (0...grid.height).each do |y|
    line = (0...grid.width).map do |x|
      grid.cell_at(x: x, y: y) == CellState::ALIVE ? ALIVE_CHAR : DEAD_CHAR
    end.join(" ")
    puts line
  end
end

grid = Grid.with(width: WIDTH, height: HEIGHT, live_cells: pattern_cells)
game = GameOfLife.new(neighbour_query_factory: adapter_class)

generation = 0
begin
  loop do
    render(grid, generation, TOPOLOGY, PATTERN)
    sleep TICK_DELAY
    grid = game.tick(grid: grid)
    generation += 1
  end
rescue Interrupt
  puts "\nStopped at generation #{generation}"
end
