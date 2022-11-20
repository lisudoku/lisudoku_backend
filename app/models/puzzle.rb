# - public_id: id used in the public url of the puzzle (don't want to be guessable)
# - variant: classic or any other variant
# - difficulty: duh!
# - constraints: a big json describing the puzzle (grid size, regions, thermos)
# - solution: the unique solution to the puzzle
# - tags: TBD
class Puzzle < ApplicationRecord
  before_create :set_public_id, :ensure_default_regions
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

  def compute_region_sizes(grid_size)
    if grid_size == 4
      [ 2, 2 ]
    elsif grid_size == 6
      [ 2, 3 ]
    else
      [ 3, 3 ]
    end
  end

  def ensure_default_regions
    return if constraints['regions'].present?

    grid_size = constraints['grid_size']
    region_height, region_width = compute_region_sizes(grid_size)

    regions = []
    (grid_size / region_height).times.each do |region_row_index|
      (grid_size / region_width).times.each do |region_col_index|
        region = []
        region_height.times.each do |row_index|
          region_width.times.each do |col_index|
            region << {
              row: region_row_index * region_height + row_index,
              col: region_col_index * region_width + col_index,
            }
          end
        end
        regions << region
      end
    end

    constraints['regions'] = regions
  end
end
