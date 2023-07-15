class UserSolution < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :puzzle

  def self.cached_all
    Rails.cache.fetch('user_solutions', expires_in: 24.hours) do
      order(id: :desc).limit(100).to_a
    end
  end
end
