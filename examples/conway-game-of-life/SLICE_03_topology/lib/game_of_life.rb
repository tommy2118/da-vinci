# frozen_string_literal: true

require "bounded_grid_adapter"
require "conway_rule"
require "grid"

class GameOfLife

  def initialize(neighbour_query_factory: BoundedGridAdapter, rule: ConwayRule.new)
    @neighbour_query_factory = neighbour_query_factory
    @rule = rule
  end

  def tick(grid:)
    ensure_positive_dimensions!(grid)
    apply_rules_to(grid)
  end

  private

  def apply_rules_to(grid)
    query = @neighbour_query_factory.new(grid: grid)
    live_cells = cells_in(grid).select do |x, y|
      apply_rule(x: x, y: y, grid: grid, query: query) == CellState::ALIVE
    end
    Grid.with(width: grid.width, height: grid.height, live_cells: live_cells)
  end

  def cells_in(grid)
    (0...grid.width).flat_map { |x| (0...grid.height).map { |y| [x, y] } }
  end

  def apply_rule(x:, y:, grid:, query:)
    @rule.next_state(state: grid.cell_at(x: x, y: y), neighbour_count: query.count_live_neighbours(x: x, y: y))
  end

  def ensure_positive_dimensions!(grid)
    raise ArgumentError.new("grid must have positive dimensions") unless grid.width.positive? && grid.height.positive?
  end
end
