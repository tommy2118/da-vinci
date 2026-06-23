# frozen_string_literal: true

require "cell_state"

class BoundedGridAdapter

  def initialize(grid:)
    @grid = grid
  end

  def count_live_neighbours(x:, y:)
    @grid.cell_at(x: x, y: y)

    count = 0
    (-1..1).each do |dx|
      (-1..1).each do |dy|
        next if dx.zero? && dy.zero?
        nx, ny = x + dx, y + dy 
        next unless nx.between?(0, @grid.width - 1) && ny.between?(0, @grid.height - 1)
        count += 1 if @grid.cell_at(x: nx, y: ny) == CellState::ALIVE
      end
    end
    count
  end
end

