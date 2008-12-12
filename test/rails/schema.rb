# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20080729045550) do

  # standard pomodo models
  create_table "locations", :force => true do |t|
    t.string   "name"
    t.text     "notes"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notes", :force => true do |t|
    t.text     "content"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.text     "notes"
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "completed"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tasks", :force => true do |t|
    t.string   "name"
    t.text     "notes"
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean  "completed"
    t.boolean  "next_action"
    t.integer  "project_id"
    t.integer  "location_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  # all simple properties test model
  create_table "simple_properties", :force => true do |t|
    t.string  "name"
    t.integer "amount"
    t.float   "price"
    t.decimal "quantity"
    t.boolean "available"
    t.date    "delivered_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.time    "sold_on"
  end

end
