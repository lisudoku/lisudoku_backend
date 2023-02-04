# - public_id: id used in the public url of the puzzle (don't want to be guessable)
# - variant: classic or any other variant
# - difficulty: duh!
# - constraints: a big json describing the puzzle (grid size, regions, thermos)
# - solution: the unique solution to the puzzle
# - tags: TBD
# - source_collection_id: its main collection (which is display on the puzzle page)
class Puzzle < ApplicationRecord
  before_validation :set_public_id, :ensure_default_regions
  after_save :update_collection_memberships

  belongs_to :source_collection, class_name: 'PuzzleCollection', optional: true
  has_many :puzzle_collections_puzzles, dependent: :destroy
  has_many :puzzle_collections, through: :puzzle_collections_puzzles

  delegate :id, to: :source_collection, prefix: true, allow_nil: true
  delegate :name, to: :source_collection, prefix: true, allow_nil: true

  validates :difficulty, presence: true
  validates :variant, presence: true
  validates :constraints, presence: true
  validate :check_constraints
  validates :solution, presence: true
  validate :check_solution

  enum variant: %w[
    arrow antiknight classic diagonal extraregions irregular killer kropki mixed oddeven thermo topbot
  ].index_by(&:itself)
  enum difficulty: %w[
    easy4x4 easy6x6 hard6x6 easy9x9 medium9x9 hard9x9
  ].index_by(&:itself)

  def self.all_ids(puzzle_filters)
    Rails.cache.fetch(self.puzzle_ids_cache_key(puzzle_filters), expires_in: 24.hours) do
      Puzzle.where(puzzle_filters).select(:public_id).pluck(:public_id)
    end
  end

  def invalidate_puzzle_cache
    puzzle_filters = {
      variant: variant,
      difficulty: difficulty,
    }
    Rails.cache.delete(self.class.puzzle_ids_cache_key(puzzle_filters))
  end

  private

  def self.puzzle_ids_cache_key(puzzle_filters)
    "puzzle_ids_#{puzzle_filters.values.join}"
  end

  def set_public_id
    self.public_id ||= SecureRandom.urlsafe_base64(15)
  end

  def update_collection_memberships
    if source_collection_id == source_collection_id_before_last_save
      return
    end

    if source_collection_id.present?
      puzzle_collections_puzzles.where(puzzle_collection_id: source_collection_id).first_or_create
    end

    if source_collection_id_before_last_save.present?
      puzzle_collections_puzzles.find_by(
        puzzle_collection_id: source_collection_id_before_last_save,
      ).destroy!
    end
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
