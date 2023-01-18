class AddSourceToPuzzles < ActiveRecord::Migration[7.0]
  def change
    change_table :puzzles, bulk: true do |t|
      t.string :source_name
      t.string :source_url
    end
  end
end
