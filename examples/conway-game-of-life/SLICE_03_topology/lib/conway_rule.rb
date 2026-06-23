# frozen_string_literal: true

class ConwayRule

  def next_state(state:, neighbour_count:)
    return CellState::ALIVE if neighbour_count == 3
    return CellState::ALIVE if neighbour_count == 2 && state == CellState::ALIVE
    CellState::DEAD
  end
end
