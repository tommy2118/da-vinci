# frozen_string_literal: true

require "spec_helper"
require "bounded_grid_adapter"
require "grid"
require "cell_state"

RSpec.describe BoundedGridAdapter do

  it_behaves_like "a NeighbourQuery"

  describe "#count_live_neighbours" do
    it "returns the correct count when multiple live neighbours surround a cell" do
      grid = Grid.with(width: 3, height: 3, live_cells: [[0, 0], [0, 1], [0, 2]])
      adapter = described_class.new(grid: grid)
      expect(adapter.count_live_neighbours(x: 1, y: 1)).to eq(3)
    end

    it "handles a cell at the edge without crashing (off-grid neighbours = 0)" do
      grid = Grid.with(width: 3, height: 3, live_cells: [[0, 0], [1, 1], [0, 1]])
      adapter = described_class.new(grid: grid)
      expect(adapter.count_live_neighbours(x: 2, y: 1)).to eq(1)
    end

    it "handles a cell at the corner without crashing" do
      grid = Grid.with(width: 3, height: 3, live_cells: [[0, 0], [1, 1], [0, 1]])
      adapter = described_class.new(grid: grid)
      expect(adapter.count_live_neighbours(x: 2, y: 2)).to eq(1)
    end

    it "raises IndexError when the query coord is out-of-bounds" do
      grid = Grid.with(width: 3, height: 3, live_cells: [[0, 0], [1, 1], [0, 1]])
      adapter = described_class.new(grid: grid)
      expect { adapter.count_live_neighbours(x: -1, y: 4) }.to raise_error(IndexError)
    end
  end
end
