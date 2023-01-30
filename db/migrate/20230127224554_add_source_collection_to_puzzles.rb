class AddSourceCollectionToPuzzles < ActiveRecord::Migration[7.0]
  def change
    add_reference :puzzles, :source_collection, foreign_key: { to_table: :puzzle_collections }
  end
end
