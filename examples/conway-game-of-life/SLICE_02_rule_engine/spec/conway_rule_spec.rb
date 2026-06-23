# frozen_string_literal: true

require "spec_helper"
require "conway_rule"
require "cell_state"

RSpec.describe ConwayRule do
  describe "#next_state" do
    describe "stasis" do
      let(:state) { CellState::DEAD }

      it "with no neighbours" do
        expect(described_class.new.next_state(state: state, neighbour_count: 0)).to eq(CellState::DEAD)
      end

      it "with two neighbours" do
        expect(described_class.new.next_state(state: state, neighbour_count: 2)).to eq(CellState::DEAD)
      end
    end

    describe "birth" do
      let(:state) { CellState::DEAD }

      it "with three neighbours" do
        expect(described_class.new.next_state(state: state, neighbour_count: 3)).to eq(CellState::ALIVE)
      end
    end

    describe "survival" do
      let(:state) { CellState::ALIVE }

      it "with two neighbours" do
        expect(described_class.new.next_state(state: state, neighbour_count: 2)).to eq(CellState::ALIVE)
      end

      it "with three neighbours" do
        expect(described_class.new.next_state(state: state, neighbour_count: 3)).to eq(CellState::ALIVE)
      end
    end

    describe "over-population" do
      let(:state) { CellState::ALIVE }

      it "with more than three neighbours" do
        expect(described_class.new.next_state(state: state, neighbour_count: 4)).to eq(CellState::DEAD)
      end

    end

    describe "under-population" do
      let(:state) { CellState::ALIVE }

      it "with no neighbours" do
        expect(described_class.new.next_state(state: state, neighbour_count: 0)).to eq(CellState::DEAD)
      end

      it "with less than two neighbours" do
        expect(described_class.new.next_state(state: state, neighbour_count: 1)).to eq(CellState::DEAD)
      end
    end
  end
end

