class PuzzleCollectionsPuzzle < ApplicationRecord
  belongs_to :puzzle_collection
  belongs_to :puzzle
end
