# frozen_string_literal: true

require "spec_helper"
require "game_of_life"
require "grid"

# Proof grammar:
# ? [C]/[O]/[P] lines in ANATOMY.md become real assertions here.

RSpec.describe "tick_generation — slice 01: walking skeleton" do
  let(:game) { GameOfLife.new }

  let(:vertical_blinker) do
    Grid.with(width: 3, height: 3, live_cells: [[1, 0], [1, 1], [1, 2]])
  end

  let(:horizontal_blinker) do
    Grid.with(width: 3, height: 3, live_cells: [[0, 1], [1, 1], [2, 1]])
  end

  it "tick advances a vertical blinker to a horizontal blinker through real wiring" do
    expect(game.tick(grid: vertical_blinker)).to eq(horizontal_blinker)
  end
end
