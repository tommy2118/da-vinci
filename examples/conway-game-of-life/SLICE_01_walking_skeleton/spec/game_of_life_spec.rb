# frozen_string_literal: true

require "spec_helper"
require "game_of_life"
require "grid"


RSpec.describe GameOfLife do
  let(:any_grid) { Grid.with(width: 3, height: 3, live_cells: []) }
  let(:factory) { double("NeighbourQuery factory") }
  let(:query) { double("NeighbourQuery") }

  it "tick returns a Grid" do
    game = described_class.new
    expect(game.tick(grid: any_grid)).to be_a(Grid)
  end
  

  before do
    allow(factory).to receive(:new).and_return(query)
    allow(query).to receive(:count_live_neighbours).and_return(0)
  end 

  it "asks the injected neighbour factory to wrap the input grid" do
    game = described_class.new(neighbour_query_factory: factory)
    game.tick(grid: any_grid)
    expect(factory).to have_received(:new).with(grid: any_grid)
  end

  it "queries the resulting NeighbourQuery" do
    game = described_class.new(neighbour_query_factory: factory)
    game.tick(grid: any_grid)
    expect(query).to have_received(:count_live_neighbours).at_least(:once)
  end
end
