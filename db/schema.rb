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

ActiveRecord::Schema[7.0].define(version: 2023_02_06_222130) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "jwt_denylist", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp", null: false
    t.index ["jti"], name: "index_jwt_denylist_on_jti"
  end

  create_table "puzzle_collections", force: :cascade do |t|
    t.string "name"
    t.string "url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "puzzle_collections_puzzles", force: :cascade do |t|
    t.bigint "puzzle_collection_id"
    t.bigint "puzzle_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["puzzle_collection_id", "puzzle_id"], name: "unique_collection_membership", unique: true
    t.index ["puzzle_collection_id"], name: "index_puzzle_collections_puzzles_on_puzzle_collection_id"
    t.index ["puzzle_id"], name: "index_puzzle_collections_puzzles_on_puzzle_id"
  end

  create_table "puzzles", force: :cascade do |t|
    t.string "public_id"
    t.string "variant", null: false
    t.string "difficulty", null: false
    t.json "constraints", null: false
    t.json "solution", null: false
    t.json "tags"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "source_name"
    t.string "source_url"
    t.bigint "source_collection_id"
    t.index ["public_id"], name: "index_puzzles_on_public_id", unique: true
    t.index ["source_collection_id"], name: "index_puzzles_on_source_collection_id"
    t.index ["variant", "difficulty"], name: "index_puzzles_on_variant_and_difficulty"
    t.index ["variant"], name: "index_puzzles_on_variant"
  end

  create_table "user_solutions", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "puzzle_id"
    t.json "steps"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["puzzle_id"], name: "index_user_solutions_on_puzzle_id"
    t.index ["user_id"], name: "index_user_solutions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "username", default: "", null: false
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "puzzle_collections_puzzles", "puzzle_collections"
  add_foreign_key "puzzle_collections_puzzles", "puzzles"
  add_foreign_key "puzzles", "puzzle_collections", column: "source_collection_id"
  add_foreign_key "user_solutions", "puzzles"
  add_foreign_key "user_solutions", "users"
end
