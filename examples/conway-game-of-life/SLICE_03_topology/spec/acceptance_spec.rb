# frozen_string_literal: true

# Acceptance test for Slice 03 — topology (conway-game-of-life).
#
# This file is what *ends* the rock drill and starts implementation. When first
# executed against an empty codebase, it should fail on real ASSERTIONS
# (expect(...).to ...), not on plumbing (NameError, NoMethodError on nil).
# The right shape of red is a real assertion failure against real wiring.
#
# Drilled anatomy: ../ANATOMY.md (stations 3-7)
# Happy-path walk this test pins: ANATOMY.md Walk-through (four-corners stable on torus)

require "spec_helper"
require "game_of_life"
require "grid"
require "toroidal_grid_adapter"

RSpec.describe "tick_generation — slice 03: topology (toroidal substitution)" do
  let(:game) { GameOfLife.new(neighbour_query_factory: ToroidalGridAdapter) }

  let(:four_corners) do
    Grid.with(width: 3, height: 3, live_cells: [[0, 0], [0, 2], [2, 0], [2, 2]])
  end

  it "with the toroidal adapter injected, the four-corners pattern is stable on a 3×3 torus" do
    expect(game.tick(grid: four_corners)).to eq(four_corners)
  end
end
