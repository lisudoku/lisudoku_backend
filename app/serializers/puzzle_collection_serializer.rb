class PuzzleCollectionSerializer < ActiveModel::Serializer
  attributes :id, :name, :url, :puzzles
end
