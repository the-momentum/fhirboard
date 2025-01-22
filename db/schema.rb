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

ActiveRecord::Schema[8.0].define(version: 2025_01_17_234753) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "analyses", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "export_path_url"
    t.bigint "session_id"
    t.boolean "sample", default: false
    t.index ["session_id"], name: "index_analyses_on_session_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "superset_username"
    t.string "superset_password"
    t.string "superset_email"
    t.integer "superset_db_connection_id"
    t.index ["token"], name: "index_sessions_on_token", unique: true
  end

  create_table "settings", force: :cascade do |t|
    t.string "key", null: false
    t.text "value"
    t.string "value_type", default: "string"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_settings_on_key", unique: true
  end

  create_table "view_definitions", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.jsonb "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "duck_db_query"
    t.bigint "analysis_id", null: false
    t.bigint "session_id"
    t.index ["analysis_id"], name: "index_view_definitions_on_analysis_id"
    t.index ["session_id"], name: "index_view_definitions_on_session_id"
  end

  add_foreign_key "analyses", "sessions"
  add_foreign_key "view_definitions", "analyses"
  add_foreign_key "view_definitions", "sessions"
end
