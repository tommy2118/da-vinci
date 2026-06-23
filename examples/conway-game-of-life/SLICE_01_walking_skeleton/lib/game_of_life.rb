# frozen_string_literal: true

require "bounded_grid_adapter"
require "grid"

class GameOfLife

  def initialize(neighbour_query_factory: BoundedGridAdapter)
    @neighbour_query_factory = neighbour_query_factory
  end

  def tick(grid:)
    query = @neighbour_query_factory.new(grid: grid)
    query.count_live_neighbours(x: 1, y: 1)
    Grid.with(width: 3, height: 3, live_cells: [[0,1], [1, 1], [2, 1]])
  end
end



