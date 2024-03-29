# - puzzle_id: which puzzle is this generated from
# - variant: duplicate of puzzle.variant for performance
# - grid: the grid in string form (fixed_numbers + some progress)
# - technique: the technique that should be applied (NakedSingle, HiddenSingle, singles (means both))
# - solutions: array of correct digit deduction using the technique (cell + value)
# - solve_count: number of solves
class TrainerPuzzle < ApplicationRecord
  belongs_to :puzzle

  def self.all_ids(trainer_puzzle_filters)
    Rails.cache.fetch(self.ids_cache_key(trainer_puzzle_filters), expires_in: 24.hours) do
      TrainerPuzzle.where(trainer_puzzle_filters).ids
    end
  end

  def puzzle_public_id
    puzzle.public_id
  end

  private

  def self.ids_cache_key(trainer_puzzle_filters)
    "trainer_puzzle_ids_#{trainer_puzzle_filters.values.join}"
  end
end
