# frozen_string_literal: true

require "spec_helper"
require "game_of_life"

RSpec.describe GameOfLife do
 let(:grid) { double("Grid", width: 1, height: 1, cell_at: :placeholder_state)  } 
 let(:query) { double("NeighbourQuery", count_live_neighbours: 0)}
 let(:factory) { double("NeighbourQuery factory") }
 let(:rule) { double("ConwayRule", next_state: :placeholder_state)  }

 before do
   allow(factory).to receive(:new).and_return(query)
 end

 it "asks the rule for the next state at least once per tick" do
   game = described_class.new(neighbour_query_factory: factory, rule: rule)
   game.tick(grid: grid)
   expect(rule).to have_received(:next_state).at_least(:once)
 end

 it "asks the rule for every cell of the grid" do
   multi_cell_grid = double("Grid", width: 2, height: 2, cell_at: :placeholder_state)
   game = described_class.new(neighbour_query_factory: factory, rule: rule)
   game.tick(grid: multi_cell_grid)
   expect(rule).to have_received(:next_state).exactly(4).times
 end

 it "asks the grid for cell_at at each (x, y) coordinate", :aggregate_failures do
   multi_cell_grid = double("Grid", width: 2, height: 2, cell_at: :placeholder_state)
   game = described_class.new(neighbour_query_factory: factory, rule: rule)
   game.tick(grid: multi_cell_grid)
   expect(multi_cell_grid).to have_received(:cell_at).with(x: 0, y: 0)
   expect(multi_cell_grid).to have_received(:cell_at).with(x: 0, y: 1)
   expect(multi_cell_grid).to have_received(:cell_at).with(x: 1, y: 0)
   expect(multi_cell_grid).to have_received(:cell_at).with(x: 1, y: 1)
 end

 it "passes the cell's state from cell_at to rule.next_state as state:" do
   game = described_class.new(neighbour_query_factory: factory, rule: rule)
   game.tick(grid: grid)
   expect(rule).to have_received(:next_state).with(state: :placeholder_state, neighbour_count: anything)
 end

 it "asks the factory for a NeighbourQuery wrapping the input grid" do
   game = described_class.new(neighbour_query_factory: factory, rule: rule)
   game.tick(grid: grid)
   expect(factory).to have_received(:new).with(grid: grid)
 end

 it "asks the query for live-neighbour counts at each (x, y) coordinate", :aggregate_failures do
   multi_cell_grid = double("Grid", width: 2, height: 2, cell_at: :placeholder_state)
   game = described_class.new(neighbour_query_factory: factory, rule: rule)
   game.tick(grid: multi_cell_grid)
   expect(query).to have_received(:count_live_neighbours).with(x: 0, y: 0)
   expect(query).to have_received(:count_live_neighbours).with(x: 0, y: 1)
   expect(query).to have_received(:count_live_neighbours).with(x: 1, y: 0)
   expect(query).to have_received(:count_live_neighbours).with(x: 1, y: 1)
 end

 it "passes the query's count to rule.next_state as neighbour_count" do
   allow(query).to receive(:count_live_neighbours).and_return(7)
   game = described_class.new(neighbour_query_factory: factory, rule: rule)
   game.tick(grid: grid)
   expect(rule).to have_received(:next_state).with(state: anything, neighbour_count: 7)
 end

 it "raises ArgumentError when the grid has zero width or height", :aggregate_failures do
   zero_width = double("Grid", width: 0, height: 3)
   zero_height = double("Grid", width: 3, height: 0)
   game = described_class.new(neighbour_query_factory: factory, rule: rule)
   expect { game.tick(grid: zero_width) }.to raise_error(ArgumentError, "grid must have positive dimensions")
   expect { game.tick(grid: zero_height) }.to raise_error(ArgumentError, "grid must have positive dimensions")
 end
end
