# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161003002207) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "dictionaries", force: :cascade do |t|
    t.string   "word",                        null: false
    t.string   "first_character",             null: false
    t.string   "definition_url"
    t.integer  "interested?",     default: 0, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "drop_checks", force: :cascade do |t|
    t.integer  "status_code"
    t.integer  "wanted_domain_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.datetime "first_registered_date"
    t.datetime "last_updated_date"
    t.datetime "expiry_date"
    t.datetime "grace_period_ends_date"
    t.index ["wanted_domain_id"], name: "index_drop_checks_on_wanted_domain_id", using: :btree
  end

  create_table "wanted_domains", force: :cascade do |t|
    t.string   "name",                               null: false
    t.string   "tld",                                null: false
    t.integer  "checked?",               default: 0, null: false
    t.string   "status"
    t.datetime "first_registered_date"
    t.datetime "last_updated_date"
    t.datetime "expiry_date"
    t.datetime "grace_period_ends_date"
    t.string   "backorder"
    t.string   "owner_name"
    t.string   "organization_name"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "status_code"
    t.integer  "backorder_status"
  end

end
