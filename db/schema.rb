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

ActiveRecord::Schema.define(version: 20170412013028) do

  create_table "infected_flags", force: :cascade do |t|
    t.integer "infected_id"
    t.integer "reporter_id"
    t.index ["infected_id", "reporter_id"], name: "index_infected_flags_on_infected_id_and_reporter_id", unique: true
  end

  create_table "resources", force: :cascade do |t|
    t.string   "name",       limit: 50, null: false
    t.integer  "points",                null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "survivor_items", force: :cascade do |t|
    t.integer "survivor_id"
    t.integer "resource_id"
    t.integer "quantity",    default: 0, null: false
    t.index ["resource_id"], name: "index_survivor_items_on_resource_id"
    t.index ["survivor_id", "resource_id"], name: "index_survivor_items_on_survivor_id_and_resource_id", unique: true
    t.index ["survivor_id"], name: "index_survivor_items_on_survivor_id"
  end

  create_table "survivors", force: :cascade do |t|
    t.string   "name",               limit: 255,                                      null: false
    t.integer  "age",                                                                 null: false
    t.integer  "gender",                                                              null: false
    t.decimal  "last_location_lati",             precision: 10, scale: 6,             null: false
    t.decimal  "last_location_long",             precision: 10, scale: 6,             null: false
    t.integer  "status",                                                  default: 0
    t.integer  "flag_counter",                                            default: 0
    t.datetime "created_at",                                                          null: false
    t.datetime "updated_at",                                                          null: false
    t.integer  "flags_count",                                             default: 0, null: false
  end

end
