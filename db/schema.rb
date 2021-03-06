# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_02_25_093638) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "actions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "campaign_id", null: false
    t.bigint "legislator_id", null: false
    t.string "status"
    t.datetime "date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "complete"
    t.string "kind"
    t.index ["campaign_id"], name: "index_actions_on_campaign_id"
    t.index ["legislator_id"], name: "index_actions_on_legislator_id"
    t.index ["user_id"], name: "index_actions_on_user_id"
  end

  create_table "call_lists", force: :cascade do |t|
    t.bigint "campaign_id", null: false
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["campaign_id"], name: "index_call_lists_on_campaign_id"
  end

  create_table "calls", force: :cascade do |t|
    t.bigint "action_id", null: false
    t.string "outcome"
    t.integer "duration"
    t.string "notes"
    t.bigint "call_list_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "commitment"
    t.index ["action_id"], name: "index_calls_on_action_id"
    t.index ["call_list_id"], name: "index_calls_on_call_list_id"
  end

  create_table "campaigns", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_campaigns_on_user_id"
  end

  create_table "committee_legislators", force: :cascade do |t|
    t.bigint "legislator_id", null: false
    t.bigint "committee_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["committee_id"], name: "index_committee_legislators_on_committee_id"
    t.index ["legislator_id"], name: "index_committee_legislators_on_legislator_id"
  end

  create_table "committees", force: :cascade do |t|
    t.string "name"
    t.string "chamber"
    t.string "open_states_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "contact_infos", force: :cascade do |t|
    t.string "kind"
    t.string "value"
    t.string "note"
    t.bigint "legislator_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["legislator_id"], name: "index_contact_infos_on_legislator_id"
  end

  create_table "legislators", force: :cascade do |t|
    t.string "name"
    t.string "family_name"
    t.string "given_name"
    t.string "party"
    t.string "chamber"
    t.integer "district"
    t.string "twitter"
    t.string "email"
    t.string "image"
    t.string "open_states_id"
    t.string "geo"
    t.string "role"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "notes", force: :cascade do |t|
    t.string "contents"
    t.bigint "user_id", null: false
    t.bigint "legislator_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["legislator_id"], name: "index_notes_on_legislator_id"
    t.index ["user_id", "legislator_id"], name: "index_notes_on_user_id_and_legislator_id", unique: true
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "password_digest"
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "user_id"
  end

  add_foreign_key "actions", "campaigns"
  add_foreign_key "actions", "legislators"
  add_foreign_key "actions", "users"
  add_foreign_key "call_lists", "campaigns"
  add_foreign_key "calls", "actions"
  add_foreign_key "calls", "call_lists"
  add_foreign_key "campaigns", "users"
  add_foreign_key "committee_legislators", "committees"
  add_foreign_key "committee_legislators", "legislators"
  add_foreign_key "contact_infos", "legislators"
  add_foreign_key "notes", "legislators"
  add_foreign_key "notes", "users"
end
