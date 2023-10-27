class TrainerPuzzleSerializer < ActiveModel::Serializer
  attributes :id, :variant, :grid, :technique, :solutions
  attribute :puzzle_public_id, key: :puzzle_id
end
