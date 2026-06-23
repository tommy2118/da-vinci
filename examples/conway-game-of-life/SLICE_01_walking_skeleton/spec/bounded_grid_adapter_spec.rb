# frozen_string_literal: true

require "spec_helper"
require "bounded_grid_adapter"
require "grid"

RSpec.describe BoundedGridAdapter do
 describe "#count_live_neighbours" do
   let(:empty_grid) { Grid.with(width: 3, height: 3, live_cells: []) }
   let(:adapter) { described_class.new(grid: empty_grid) }

   it "returns zero when the grid has no live cells" do
     expect(adapter.count_live_neighbours(x: 1, y: 1)).to eq(0) 
   end
 end
end

