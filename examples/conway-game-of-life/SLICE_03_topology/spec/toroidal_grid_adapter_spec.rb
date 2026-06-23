# frozen_string_literal: true

require "spec_helper"
require "toroidal_grid_adapter"
require "grid"
require "cell_state"

RSpec.describe ToroidalGridAdapter do

  it_behaves_like "a NeighbourQuery"

  describe "#count_live_neighbours" do
    it "counts a live cell on the left edge as a neighbour when querying a cell on the right edge" do
      grid = Grid.with(width: 3, height: 3, live_cells: [[2, 2], [1, 1], [0, 1]])
      adapter = described_class.new(grid: grid)
      expect(adapter.count_live_neighbours(x: 2, y: 1)).to eq(3)
    end

    it "counts a live cell on the top edge as a neighbour when querying a cell on the bottom edge" do
      grid = Grid.with(width: 3, height: 3, live_cells: [[0, 2], [1, 0], [2, 2]])
      adapter = described_class.new(grid: grid)
      expect(adapter.count_live_neighbours(x: 1, y: 2)).to eq(3)
    end

    it "counts a live cell at the opposite corner as a neighbour" do
      grid = Grid.with(width: 3, height: 3, live_cells: [[0, 1], [1, 0], [2, 2]])
      adapter = described_class.new(grid: grid)
      expect(adapter.count_live_neighbours(x: 0, y: 0)).to eq(3)
    end
  end
end



