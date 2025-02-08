class UserSolutionSerializer < ActiveModel::Serializer
  attributes :id, :steps, :created_at, :solve_time
  attribute :puzzle do
    object.puzzle.slice(:id, :public_id, :variant, :difficulty)
  end
end
