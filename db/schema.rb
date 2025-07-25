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

ActiveRecord::Schema[8.0].define(version: 2025_07_25_043300) do
  create_table "businesses", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.text "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "owner_id", null: false
    t.index ["owner_id"], name: "index_businesses_on_owner_id"
  end

  create_table "devices", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "device_id", null: false
    t.bigint "qr_id"
    t.bigint "marquee_id"
    t.bigint "slide_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_id"], name: "index_devices_on_device_id", unique: true
    t.index ["marquee_id"], name: "index_devices_on_marquee_id"
    t.index ["qr_id"], name: "index_devices_on_qr_id"
    t.index ["slide_id"], name: "index_devices_on_slide_id"
  end

  create_table "marquees", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.text "message", null: false
    t.string "background_color", null: false
    t.string "text_color", null: false
    t.bigint "business_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_marquees_on_business_id"
  end

  create_table "media", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "media_type", null: false
    t.string "file_path", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "playlist_media", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "playlist_id", null: false
    t.bigint "media_id", null: false
    t.integer "duration", null: false
    t.text "description", null: false
    t.string "text_size", null: false
    t.string "description_position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["media_id"], name: "index_playlist_media_on_media_id"
    t.index ["playlist_id", "media_id"], name: "index_playlist_media_on_playlist_id_and_media_id", unique: true
    t.index ["playlist_id"], name: "index_playlist_media_on_playlist_id"
  end

  create_table "playlists", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "slide_id", null: false
    t.bigint "qr_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["qr_id"], name: "index_playlists_on_qr_id"
    t.index ["slide_id"], name: "index_playlists_on_slide_id"
  end

  create_table "qrs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.text "info", null: false
    t.string "position", null: false
    t.bigint "business_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_qrs_on_business_id"
  end

  create_table "slide_media", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "slide_id", null: false
    t.bigint "media_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["media_id"], name: "index_slide_media_on_media_id"
    t.index ["slide_id", "media_id"], name: "index_slide_media_on_slide_id_and_media_id", unique: true
    t.index ["slide_id"], name: "index_slide_media_on_slide_id"
  end

  create_table "slides", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "business_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_slides_on_business_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "role", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest", null: false
    t.string "phone"
    t.boolean "enabled", default: true
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "businesses", "users", column: "owner_id"
  add_foreign_key "devices", "marquees"
  add_foreign_key "devices", "qrs"
  add_foreign_key "devices", "slides"
  add_foreign_key "marquees", "businesses"
  add_foreign_key "playlist_media", "media", column: "media_id"
  add_foreign_key "playlist_media", "playlists"
  add_foreign_key "playlists", "qrs"
  add_foreign_key "playlists", "slides"
  add_foreign_key "qrs", "businesses"
  add_foreign_key "slide_media", "media", column: "media_id"
  add_foreign_key "slide_media", "slides"
  add_foreign_key "slides", "businesses"
end
