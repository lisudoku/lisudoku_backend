class UserSolution < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :puzzle

  def self.cached_all
    Rails.cache.fetch('user_solutions', expires_in: 24.hours) do
      order(id: :desc).limit(100).to_a
    end
  end

  def self.cached_puzzle_ids
    Rails.cache.fetch('user_solutions_puzzle_ids', expires_in: 24.hours) do
      distinct.pluck(:puzzle_id)
    end
  end
end
