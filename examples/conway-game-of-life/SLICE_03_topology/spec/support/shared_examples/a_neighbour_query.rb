# frozen_string_literal: true

shared_examples "a NeighbourQuery" do
  it "returns 0 for any cell on an empty grid" do
    grid = Grid.with(width: 3, height: 3, live_cells: [])
    adapter = described_class.new(grid: grid)
    expect(adapter.count_live_neighbours(x: 1, y: 1)).to eq(0)
  end

  it "returns 1 for a cell with exactly one live neighbour" do
    # Live cell at (1, 0) is "directly above" (1, 1) — adjacent under
    # 8-neighbour topologies (Bounded, Toroidal) AND hex odd-r topology.
    # Keeps the contract truly universal across all NeighbourQuery adapters.
    grid = Grid.with(width: 3, height: 3, live_cells: [[1, 0]])
    adapter = described_class.new(grid: grid)
    expect(adapter.count_live_neighbours(x: 1, y: 1)).to eq(1)
  end

  it "does not count the cell itself as its own neighbour" do
    grid = Grid.with(width: 3, height: 3, live_cells: [[1, 0], [1, 1]])
    adapter = described_class.new(grid: grid)
    expect(adapter.count_live_neighbours(x: 1, y: 1)).to eq(1)
  end
end



