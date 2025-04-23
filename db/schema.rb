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

ActiveRecord::Schema[8.0].define(version: 2025_04_23_151714) do
  create_table "sleep_records", force: :cascade do |t|
    t.integer "user_id"
    t.datetime "clock_in"
    t.integer "duration_seconds"
    t.index ["duration_seconds"], name: "index_sleep_records_on_duration_seconds"
    t.index ["user_id", "clock_in"], name: "index_sleep_records_on_user_id_and_clock_in"
    t.index ["user_id"], name: "index_sleep_records_on_user_id"
  end

  create_table "user_followers", primary_key: ["user_id", "follower"], force: :cascade do |t|
    t.integer "user_id"
    t.integer "follower"
    t.datetime "created_at"
    t.index ["follower"], name: "index_user_followers_on_follower"
    t.index ["user_id"], name: "index_user_followers_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
  end
end
