# - public_id: id used in the public url of the puzzle (don't want to be guessable)
# - variant: classic or any other variant
# - difficulty: duh!
# - constraints: a big json describing the puzzle (grid size, regions, thermos)
# - solution: the unique solution to the puzzle
# - tags: TBD
class Puzzle < ApplicationRecord
  before_validation :set_public_id, :ensure_default_regions
  validates :constraints, presence: true
  validate :check_constraints
  validates :solution, presence: true
  validate :check_solution

  enum variant: %w[classic killer thermo arrow irregular kropki topbot diagonal mixed].index_by(&:itself)
  enum difficulty: %w[easy4x4 easy6x6 easy9x9 medium9x9 hard9x9].index_by(&:itself)

  private

  def set_public_id
    self.public_id ||= SecureRandom.urlsafe_base64(15)
  end

  def check_constraints
    %w[grid_size regions fixed_numbers].each do |key|
      errors.add(:constraints, "does not contain #{key}") unless constraints.has_key?(key)
    end
    errors.add(:constraints, 'grid_size must be 4, 6, or 9') unless constraints['grid_size'].in?([ 4, 6, 9 ])
    # TODO: check that regions has good format and covers the whole grid
    # TODO: check that fixed_numbers are unique, do not break sudoku (or other) rules
    # TODO: check that thermos has good format, each thermo has 1 < length <= grid_size
  end

  def check_solution
    return if errors.present?

    grid_size = constraints['grid_size']
    errors.add(:solution, "solution must have size #{grid_size}x#{grid_size}") unless solution.size == grid_size
    solution.each do |row|
      errors.add(:solution, "solution must have size #{grid_size}x#{grid_size}") unless row.size == grid_size
    end
    # TODO: check that the solution is valid
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
