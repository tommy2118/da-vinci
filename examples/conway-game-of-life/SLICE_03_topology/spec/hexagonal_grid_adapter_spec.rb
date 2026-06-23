# frozen_string_literal: true

require "spec_helper"
require "hexagonal_grid_adapter"
require "grid"
require "cell_state"

RSpec.describe HexagonalGridAdapter do

  it_behaves_like "a NeighbourQuery"

  describe "#count_live_neighbours" do
    it "excludes diagonal corners that aren't part of hex topology (even row)" do
      # Querying (1, 2) — even row. In 8-neighbour topology, (2, 1) would be
      # a diagonal neighbour. In odd-r hex topology, an even-row cell's
      # neighbour offsets skip the (+1, -1) diagonal — so (2, 1) is NOT counted.
      grid = Grid.with(width: 3, height: 3, live_cells: [[2, 1]])
      adapter = described_class.new(grid: grid)
      expect(adapter.count_live_neighbours(x: 1, y: 2)).to eq(0)
    end

    it "excludes diagonal corners that aren't part of hex topology (odd row)" do
      # Querying (1, 1) — odd row. In 8-neighbour topology, (0, 0) would be
      # a diagonal neighbour. In odd-r hex topology, an odd-row cell's
      # neighbour offsets skip the (-1, -1) diagonal — so (0, 0) is NOT counted.
      grid = Grid.with(width: 3, height: 3, live_cells: [[0, 0]])
      adapter = described_class.new(grid: grid)
      expect(adapter.count_live_neighbours(x: 1, y: 1)).to eq(0)
    end

    it "counts all 6 hex neighbours when surrounded (interior cell)" do
      # All 6 hex neighbours of (1, 1) on odd row: (0, 1), (2, 1), (1, 0), (2, 0), (1, 2), (2, 2)
      live_cells = [[0, 1], [2, 1], [1, 0], [2, 0], [1, 2], [2, 2]]
      grid = Grid.with(width: 3, height: 3, live_cells: live_cells)
      adapter = described_class.new(grid: grid)
      expect(adapter.count_live_neighbours(x: 1, y: 1)).to eq(6)
    end

    it "skips off-grid neighbours at the edge (bounded behaviour)" do
      # Query (1, 0) — top edge. Hex neighbours on even row:
      #   (0, 0), (2, 0), (0, -1)[off-grid], (1, -1)[off-grid], (0, 1), (1, 1)
      # 4 of 6 land in-bounds. Place a live cell at each → count is 4.
      grid = Grid.with(width: 3, height: 3, live_cells: [[0, 0], [2, 0], [0, 1], [1, 1]])
      adapter = described_class.new(grid: grid)
      expect(adapter.count_live_neighbours(x: 1, y: 0)).to eq(4)
    end
  end
end
