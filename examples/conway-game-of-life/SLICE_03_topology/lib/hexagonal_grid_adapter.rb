# frozen_string_literal: true

require "cell_state"

# NeighbourQuery adapter for a hexagonal grid using "odd-r" offset coordinates:
# odd-numbered rows are visually shifted right by half a cell width, giving each
# cell 6 neighbours (not 8). Off-grid neighbours contribute 0 (bounded edges).
class HexagonalGridAdapter
  # Neighbour offsets depend on row parity in odd-r offset coordinates.
  # Each cell has 2 same-row neighbours plus 4 above/below — total 6.
  EVEN_ROW_OFFSETS = [[-1, 0], [1, 0], [-1, -1], [0, -1], [-1, 1], [0, 1]].freeze
  ODD_ROW_OFFSETS  = [[-1, 0], [1, 0], [0, -1], [1, -1], [0, 1], [1, 1]].freeze

  def initialize(grid:)
    @grid = grid
  end

  def count_live_neighbours(x:, y:)
    offsets_for(y).count do |dx, dy|
      nx, ny = x + dx, y + dy
      next false unless nx.between?(0, @grid.width - 1) && ny.between?(0, @grid.height - 1)
      @grid.cell_at(x: nx, y: ny) == CellState::ALIVE
    end
  end

  private

  def offsets_for(y)
    y.even? ? EVEN_ROW_OFFSETS : ODD_ROW_OFFSETS
  end
end
