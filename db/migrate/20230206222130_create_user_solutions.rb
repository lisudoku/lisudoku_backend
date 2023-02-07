class CreateUserSolutions < ActiveRecord::Migration[7.0]
  def change
    create_table :user_solutions do |t|
      t.references :user, index: true, foreign_key: true
      t.references :puzzle, index: true, foreign_key: true
      t.json :steps

      t.timestamps
    end
  end
end
