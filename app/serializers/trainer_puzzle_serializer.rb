class TrainerPuzzleSerializer < ActiveModel::Serializer
  attributes :id, :variant, :grid, :technique, :solutions
end
