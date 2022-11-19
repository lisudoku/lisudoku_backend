class CreatePuzzles < ActiveRecord::Migration[7.0]
  def change
    create_table :puzzles do |t|
      t.string :public_id, index: { unique: true }
      t.string :variant, null: false, index: true
      t.string :difficulty, null: false
      t.json :constraints, null: false
      t.json :solution, null: false
      t.json :tags

      t.index %i[variant difficulty]

      t.timestamps
    end
  end
end
