class PuzzleCollection < ApplicationRecord
  before_destroy :remove_as_puzzle_source

  has_many :puzzle_collections_puzzles, dependent: :destroy
  has_many :puzzles, through: :puzzle_collections_puzzles

  private

  def remove_as_puzzle_source
    # Note: puzzles that have this collections as a source should be linked to it
    puzzles.update_all(source_collection_id: nil)
  end
end
