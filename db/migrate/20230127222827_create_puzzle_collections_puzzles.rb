class CreatePuzzleCollectionsPuzzles < ActiveRecord::Migration[7.0]
  def change
    create_table :puzzle_collections_puzzles do |t|
      t.references :puzzle_collection, index: true, foreign_key: true
      t.references :puzzle, index: true, foreign_key: true

      t.timestamps
    end

    add_index :puzzle_collections_puzzles, [:puzzle_collection_id, :puzzle_id], unique: true, name: 'unique_collection_membership'
  end
end
