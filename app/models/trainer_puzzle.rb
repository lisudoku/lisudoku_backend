# - puzzle_id: which puzzle is this generated from
# - variant: duplicate of puzzle.variant for performance
# - grid: the grid in string form (fixed_numbers + some progress)
# - technique: the technique that should be applied (NakedSingle, HiddenSingle, singles (means both))
# - solutions: array of correct digit deduction using the technique (cell + value)
# - solve_count: number of solves
class TrainerPuzzle < ApplicationRecord
end
