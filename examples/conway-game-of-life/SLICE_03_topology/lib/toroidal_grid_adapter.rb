# frozen_string_literal: true

require "cell_state"

class ToroidalGridAdapter

  def initialize(grid:)
    @grid = grid
  end

  def count_live_neighbours(x:, y:)
    count = 0
    (-1..1).each do |dx|
      (-1..1).each do |dy|
        next if dx.zero? && dy.zero?
        nx = (x + dx) % @grid.width
        ny = (y + dy) % @grid.height 
        count += 1 if @grid.cell_at(x: nx, y: ny) == CellState::ALIVE
      end
    end
    count
  end
end




