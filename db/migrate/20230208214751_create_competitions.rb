class CreateCompetitions < ActiveRecord::Migration[7.0]
  def change
    create_table :competitions do |t|
      t.string :name
      t.string :url
      t.datetime :from_date
      t.datetime :to_date
      t.references :puzzle_collection, index: true, foreign_key: true
      t.references :ib_puzzle_collection, index: true, foreign_key: { to_table: :puzzle_collections }

      t.timestamps
    end
  end
end
