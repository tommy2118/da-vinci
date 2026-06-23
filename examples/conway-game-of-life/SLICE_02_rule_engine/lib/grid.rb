# frozen_string_literal: true

require "cell_state"

class Grid

  attr_reader :width, :height

  def self.with(width:, height:, live_cells:)
    new(width: width, height: height, live_cells: live_cells)
  end

  private_class_method :new

  def initialize(width:, height:, live_cells: [])
    raise ArgumentError, "grid must have positive dimensions (got width: #{width}, height: #{height})" unless width.positive? && height.positive?

    @width = width
    @height = height
    @live_cells = live_cells
    freeze
  end

  def cell_at(x:, y:)
    raise IndexError, "coord (x: #{x}, y: #{y}) is not within the grid dimensions of #{width}×#{height}." unless x.between?(0, width - 1) && y.between?(0, height - 1)
    return CellState::ALIVE if @live_cells.include?([x, y])
    CellState::DEAD
  end

  def ==(other)
    other.is_a?(Grid) && width == other.width && height == other.height && live_cells == other.live_cells
  end

  def eql?(other)
    self == other
  end

  def hash
    [self.class, width, height, live_cells].hash
  end

  protected

  attr_reader :live_cells
end

