class PuzzleSerializer < ActiveModel::Serializer
  attributes :id, :public_id, :variant, :difficulty, :constraints,
             :source_collection_id, :source_collection_name, :author

  attribute :solved, if: -> { instance_options[:solved_puzzle_ids].present? }

  def solved
    instance_options[:solved_puzzle_ids].include?(object.id)
  end
end
