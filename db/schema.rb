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

ActiveRecord::Schema.define(version: 2019_01_19_192853) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "locations", force: :cascade do |t|
    t.point "position"
    t.float "altitude"
    t.float "accuracy"
    t.string "provider"
    t.datetime "moment"
    t.jsonb "raw"
  end

  create_table "sensor_statuses", force: :cascade do |t|
    t.integer "steps"
    t.integer "motion_type"
    t.datetime "moment"
    t.jsonb "raw"
  end

end
