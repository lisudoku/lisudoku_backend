class CreatePuzzles < ActiveRecord::Migration[7.0]
  def change
    create_table :puzzles do |t|
      t.string :public_id, index: true
      t.string :variant, null: false, index: true
      t.string :difficulty, null: false
      t.json :data
      t.json :tags
      t.json :solution

      t.index %i[variant difficulty]

      t.timestamps
    end
  end
end
