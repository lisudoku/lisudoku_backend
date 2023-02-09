FactoryBot.define do
  factory :competition do
    name { 'My Competition' }
    url { 'https://gp.worldpuzzle.org' }
    from { '2023-02-08 23:47:51' }
    to { '2023-02-12 23:47:51' }
    puzzle_collection { nil }
    ib_puzzle_collection { nil }
  end
end
