FactoryBot.define do
  factory :puzzle do
    public_id { '123456' }
    variant { Puzzle.variants[:classic] }
    difficulty { Puzzle.difficulties[:easy4x4] }
    constraints {
      {
        'grid_size': 4,
        'fixed_numbers': [],
        'regions': [],
      }
    }
    solution { [[2, 1, 4, 3], [3, 4, 1, 2], [1, 2, 3, 4], [4, 3, 2, 1]] }
  end
end
