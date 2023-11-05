class CreateTrainerPuzzles < ActiveRecord::Migration[7.0]
  def change
    create_table :trainer_puzzles do |t|
      t.references :puzzle, index: true, foreign_key: true
      t.string :variant, null: false
      t.string :grid, null: false
      t.string :technique, null: false      
      t.json :solutions, null: false
      t.integer :solve_count, null: false, default: 0
      t.integer :fail_count, null: false, default: 0

      t.timestamps
    end

    add_index :trainer_puzzles, [:puzzle_id, :grid, :technique], unique: true, name: 'unique_trainer_puzzle'
    add_index :trainer_puzzles, [:variant, :technique], name: 'trainer_puzzle_random_index'
  end
end
