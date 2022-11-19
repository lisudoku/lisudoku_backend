class PuzzleSerializer < ActiveModel::Serializer
  attributes :public_id, :variant, :difficulty, :constraints
end
