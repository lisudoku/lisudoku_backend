class AddPuzzleAuthor < ActiveRecord::Migration[7.0]
  def change
    add_column :puzzles, :author, :string
  end
end
