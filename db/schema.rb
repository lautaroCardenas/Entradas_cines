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

ActiveRecord::Schema[8.1].define(version: 2026_09_30_200001) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "cinemas", force: :cascade do |t|
    t.string "address", null: false
    t.string "city", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_cinemas_on_name", unique: true
  end

  create_table "halls", force: :cascade do |t|
    t.integer "cinema_id", null: false
    t.datetime "created_at", null: false
    t.integer "hall_type", default: 0, null: false
    t.string "name", null: false
    t.integer "rows_count", null: false
    t.integer "seats_per_row", null: false
    t.datetime "updated_at", null: false
    t.index ["cinema_id", "name"], name: "index_halls_on_cinema_id_and_name", unique: true
    t.index ["cinema_id"], name: "index_halls_on_cinema_id"
  end

  create_table "movies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "duration_minutes", null: false
    t.string "genre", null: false
    t.string "rating", null: false
    t.date "release_date"
    t.integer "status", default: 0, null: false
    t.text "synopsis"
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "screening_id", null: false
    t.decimal "service_fee", precision: 10, scale: 2, default: "0.0", null: false
    t.integer "status", default: 0, null: false
    t.decimal "total", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["screening_id"], name: "index_orders_on_screening_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "screenings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "hall_id", null: false
    t.integer "language", default: 0, null: false
    t.integer "movie_id", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.integer "screen_format", default: 0, null: false
    t.datetime "starts_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hall_id", "starts_at"], name: "index_screenings_on_hall_id_and_starts_at"
    t.index ["hall_id"], name: "index_screenings_on_hall_id"
    t.index ["movie_id"], name: "index_screenings_on_movie_id"
  end

  create_table "seats", force: :cascade do |t|
    t.boolean "accessible", default: false, null: false
    t.datetime "created_at", null: false
    t.integer "hall_id", null: false
    t.integer "number", null: false
    t.string "row", null: false
    t.datetime "updated_at", null: false
    t.index ["hall_id", "row", "number"], name: "index_seats_on_hall_id_and_row_and_number", unique: true
    t.index ["hall_id"], name: "index_seats_on_hall_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.string "token"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["token"], name: "index_sessions_on_token", unique: true
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.integer "order_id", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.integer "screening_id", null: false
    t.integer "seat_id", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_tickets_on_code", unique: true
    t.index ["order_id"], name: "index_tickets_on_order_id"
    t.index ["screening_id", "seat_id"], name: "index_tickets_on_screening_id_and_seat_id", unique: true
    t.index ["screening_id"], name: "index_tickets_on_screening_id"
    t.index ["seat_id"], name: "index_tickets_on_seat_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "halls", "cinemas"
  add_foreign_key "orders", "screenings"
  add_foreign_key "orders", "users"
  add_foreign_key "screenings", "halls"
  add_foreign_key "screenings", "movies"
  add_foreign_key "seats", "halls"
  add_foreign_key "sessions", "users"
  add_foreign_key "tickets", "orders"
  add_foreign_key "tickets", "screenings"
  add_foreign_key "tickets", "seats"
end
