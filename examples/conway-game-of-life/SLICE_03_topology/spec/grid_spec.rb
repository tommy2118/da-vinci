# frozen_string_literal: true

require "grid"
require "cell_state"

RSpec.describe Grid do
  let(:grid) { described_class.with(width: 3, height: 3, live_cells: []) }

  describe ".with" do
    it "yields a grid with the given dimensions", :aggregate_failures do
      expect(grid.width).to eq(3)
      expect(grid.height).to eq(3)
    end
  end

  describe "#cell_at" do
    describe "when there are no living cells" do
      it "returns CellState::DEAD for any in-bounds cell on an empty grid", :aggregate_failures do
        expect(grid.cell_at(x: 0, y: 0)).to eq(CellState::DEAD)
        expect(grid.cell_at(x: 1, y: 1)).to eq(CellState::DEAD)
        expect(grid.cell_at(x: 2, y: 2)).to eq(CellState::DEAD)
      end
    end

    describe "when there are living cells" do
      let(:grid) { described_class.with(width: 3, height: 3, live_cells: [[0, 0]]) }

      it "returns CellState::ALIVE at a coord where a live cell exists" do
        expect(grid.cell_at(x: 0, y: 0)).to eq(CellState::ALIVE)
      end
    end

    describe "when asked about coords not on the grid" do
      it "raises an IndexError when coords are out-of-bounds", :aggregate_failures do
        expect { grid.cell_at(x: -1, y:  0) }.to raise_error(IndexError)
        expect { grid.cell_at(x:  3, y:  0) }.to raise_error(IndexError)
        expect { grid.cell_at(x:  0, y: -1) }.to raise_error(IndexError)
        expect { grid.cell_at(x:  0, y:  3) }.to raise_error(IndexError)
      end

      it "raises with the offending coord and the grid dimensions" do
        expect { grid.cell_at(x: 99, y: 99) }.to raise_error(IndexError, /x: 99, y: 99.*3.*3/)
      end
    end
  end

  describe "value equality" do
    let(:grid) { described_class.with(width: 3, height: 3, live_cells: [[0, 0], [1, 1]]) }
    let(:other_grid) { described_class.with(width: 3, height: 3, live_cells: [[0, 0], [1, 1]]) }

    it "two grids with the same dimensions and living cells are equal" do
      expect(grid).to eq(other_grid)
    end

    it "is not equal to a non-Grid value", :aggregate_failures do
      expect(grid).not_to eq(nil)
      expect(grid).not_to eq("not a grid")
      expect(grid).not_to eq([[0, 0], [1, 1]])
    end

    it "is eql? to a value-equal Grid" do
      expect(grid).to eql(other_grid)
    end

    it "shares a hash with a value-equal Grid (Set/Hash safety)" do
      expect(grid.hash).to eq(other_grid.hash)
    end
  end

  describe "immutability" do
    it "is frozen on construction" do
      expect(grid).to be_frozen
    end
  end

  describe ".new" do
    it "is private" do
      expect { Grid.new(width: 3, height: 3, live_cells: []) }.to raise_error(NoMethodError, /private method/)
    end
  end

  describe "construction validation" do
    it "rasies ArgumentError when width is not positive", :aggregate_failures do
      expect { described_class.with(width:  0, height: 3, live_cells: []) }.to raise_error(ArgumentError)
      expect { described_class.with(width: -3, height: 3, live_cells: []) }.to raise_error(ArgumentError)
    end 

    it "raises ArgumentError when height is not positive", :aggregate_failures do
      expect { described_class.with(width: 3, height:  0, live_cells: []) }.to raise_error(ArgumentError)
      expect { described_class.with(width: 3, height: -3, live_cells: []) }.to raise_error(ArgumentError)
    end

    it "raises with a message naming the positive-dimensions requirement" do
      expect { described_class.with(width: 0, height: 3, live_cells: []) }
        .to raise_error(ArgumentError, /must have positive dimensions/)
    end
  end
end

