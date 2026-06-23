# frozen_string_literal: true

# Acceptance test for Slice 02 — rule_engine (conway-game-of-life).
#
# This file is what *ends* the rock drill and starts implementation. When first
# executed against an empty codebase, it should fail on real ASSERTIONS
# (expect(...).to ...), not on plumbing (NameError, NoMethodError on nil).
# The right shape of red is a real assertion failure against real wiring.
#
# Drilled anatomy: ../ANATOMY.md (stations 3-7)
# Happy-path walk this test pins: ANATOMY.md station 6 (vertical blinker -> horizontal blinker)

require "spec_helper"
require "game_of_life"
require "grid"

RSpec.describe "tick_generation — slice 02: rule_engine" do
  let(:game) { GameOfLife.new }

  let(:vertical_blinker) do
    Grid.with(width: 3, height: 3, live_cells: [[1, 0], [1, 1], [1, 2]])
  end

  let(:horizontal_blinker) do
    Grid.with(width: 3, height: 3, live_cells: [[0, 1], [1, 1], [2, 1]])
  end

  it "advances a vertical blinker to a horizontal blinker via real Conway rule application" do
    expect(game.tick(grid: vertical_blinker)).to eq(horizontal_blinker)
  end
end
