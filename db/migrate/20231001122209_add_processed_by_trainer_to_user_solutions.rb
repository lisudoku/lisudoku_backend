class AddProcessedByTrainerToUserSolutions < ActiveRecord::Migration[7.0]
  def change
    add_column :user_solutions, :processed_by_trainer, :boolean, null: false, default: false
    add_index :user_solutions, :processed_by_trainer, name: 'user_solutions_processed_by_trainer'
  end
end
