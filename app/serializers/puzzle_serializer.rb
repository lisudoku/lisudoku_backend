class PuzzleSerializer < ActiveModel::Serializer
  attributes :id, :public_id, :variant, :difficulty, :constraints,
             :source_collection_id, :source_collection_name
end
