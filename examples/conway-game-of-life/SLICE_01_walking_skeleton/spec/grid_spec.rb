# frozen_string_literal: true

require "spec_helper"
require "grid"

RSpec.describe Grid do
  let(:grid) { described_class.with(width: 3, height: 3, live_cells: [[1,1]]) }
  let(:other_grid) { described_class.with(width: 3, height: 3, live_cells: [[0,0]]) }

  it "is constructed via .with(width:, height:, live_cells:) and is a Grid" do
    expect(grid).to be_a(Grid)
  end

  it "is not equal to a Grid with different live cells" do
    expect(grid).not_to eq(other_grid)
  end

  it "is frozen after construction" do
    expect(grid).to be_frozen
  end

  it "rejects direct .new construction in favor of .with" do
   expect {
    described_class.new(width: 1, height: 1, live_cells: [])
   }.to raise_error(NoMethodError, /private method/) 
  end
end
