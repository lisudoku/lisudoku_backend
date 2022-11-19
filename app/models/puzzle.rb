# - public_id: id used in the public url of the puzzle (don't want to be guessable)
# - variant: classic or any other variant
# - difficulty: duh!
# - constraints: a big json describing the puzzle (grid size, regions, thermos)
# - solution: the unique solution to the puzzle
# - tags: TBD
class Puzzle < ApplicationRecord
  before_create :set_public_id
  validate :check_constraints_keys

  enum variant: %w[classic killer thermo arrow irregular kropki topbot diagonal mixed].index_by(&:itself)
  enum difficulty: %w[easy_4x4 easy_6x6 easy_9x9 medium_9x9 hard_9x9].index_by(&:itself)

  private

  def set_public_id
    self.public_id = SecureRandom.urlsafe_base64(15)
  end

  def check_constraints_keys
    errors.add(:constraints, 'constraints does not contain grid_size') unless constraints.has_key?('grid_size')
  end
end
