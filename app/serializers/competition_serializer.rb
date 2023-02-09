class CompetitionSerializer < ActiveModel::Serializer
  attributes :id, :name, :url, :from_date, :to_date,
             :puzzle_collection_id, :ib_puzzle_collection_id
end
