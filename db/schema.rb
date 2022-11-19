# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_11_18_222522) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "puzzles", force: :cascade do |t|
    t.string "public_id"
    t.string "variant", null: false
    t.string "difficulty", null: false
    t.json "constraints", null: false
    t.json "solution", null: false
    t.json "tags"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["public_id"], name: "index_puzzles_on_public_id", unique: true
    t.index ["variant", "difficulty"], name: "index_puzzles_on_variant_and_difficulty"
    t.index ["variant"], name: "index_puzzles_on_variant"
  end

end
