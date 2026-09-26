class PuzzleSerializer < ActiveModel::Serializer
  attributes :id, :public_id, :variant, :difficulty, :constraints, :author

  attribute :solved, if: -> { instance_options[:solved_puzzle_ids].present? }
  attribute :source_collection_id, if: -> { instance_options[:include_source_collection] }
  attribute :source_collection_name, if: -> { instance_options[:include_source_collection] }

  def solved
    instance_options[:solved_puzzle_ids].include?(object.id)
  end
end
