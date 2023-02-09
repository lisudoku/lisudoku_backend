class Competition < ApplicationRecord
  belongs_to :puzzle_collection, optional: true
  belongs_to :ib_puzzle_collection, class_name: 'PuzzleCollection', optional: true

  def self.invalidate_cache
    Rails.cache.delete('competitions')
    Rails.cache.delete('competitions_active')
  end
end
