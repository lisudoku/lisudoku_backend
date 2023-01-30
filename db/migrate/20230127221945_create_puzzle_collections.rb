class CreatePuzzleCollections < ActiveRecord::Migration[7.0]
  def change
    create_table :puzzle_collections do |t|
      t.string :name
      t.string :url, null: false

      t.timestamps
    end
  end
end
