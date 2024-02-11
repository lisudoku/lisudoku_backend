class AddTimeToUserSolution < ActiveRecord::Migration[7.0]
  def change
    add_column :user_solutions, :solve_time, :integer
    add_index :user_solutions, :solve_time, name: 'user_solutions_solve_time'
  end
end
