# frozen_string_literal: true

class Grid

  attr_reader :width, :height, :live_cells

  def initialize(width:, height:, live_cells:)
    @width = width
    @height = height
    @live_cells = live_cells
    freeze
  end

  def self.with(width:, height:, live_cells: [])
    new(width: width, height: height, live_cells: live_cells)
  end

  private_class_method :new

  def ==(other)
    return unless other.is_a?(Grid) 

    live_cells == other.live_cells
  end

end



