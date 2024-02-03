class PuzzleCollectionSerializer < ActiveModel::Serializer
  attributes :id, :name, :url, :puzzles

  def puzzles
    object.puzzles.order(:difficulty, :variant, :id)
  end
end
