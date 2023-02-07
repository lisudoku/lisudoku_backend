class UserSolution < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :puzzle
end
