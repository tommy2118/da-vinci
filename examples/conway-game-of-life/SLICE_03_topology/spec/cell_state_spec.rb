# frozen_string_literal: true

require "spec_helper"
require "cell_state"

RSpec.describe CellState do
  describe "when ALIVE" do
    it "exposes ALIVE as a frozen singleton value" do
      expect(CellState::ALIVE).to be_frozen
    end

    it "is not confused for any primative value", :aggregate_failures do
      expect(CellState::ALIVE).not_to eq(true)
      expect(CellState::ALIVE).not_to eq(false)
      expect(CellState::ALIVE).not_to eq(nil)
      expect(CellState::ALIVE).not_to eq(:alive)
      expect(CellState::ALIVE).not_to eq("alive")
    end
  end

  describe "when DEAD" do
    it "exposes DEAD as a frozen singleton value", :aggregate_failures do
      expect(CellState::DEAD).to be_frozen
      expect(CellState::DEAD).not_to eq(CellState::ALIVE)
    end

    it "is not confused for any primative value", :aggregate_failures do
      expect(CellState::DEAD).not_to eq(true)
      expect(CellState::DEAD).not_to eq(false)
      expect(CellState::DEAD).not_to eq(nil)
      expect(CellState::DEAD).not_to eq(:dead)
      expect(CellState::DEAD).not_to eq("dead")
    end
  end
end
