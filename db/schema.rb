# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150902101618) do

  create_table "actions", force: :cascade do |t|
    t.string   "label"
    t.integer  "node_id"
    t.integer  "package_id"
    t.integer  "script_id"
    t.boolean  "completed"
    t.boolean  "success"
    t.text     "output"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "node_comments", force: :cascade do |t|
    t.integer  "node_id"
    t.integer  "user_id"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "node_tags", force: :cascade do |t|
    t.integer  "node_id"
    t.string   "tag"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nodes", force: :cascade do |t|
    t.string   "hostname"
    t.text     "lshw_information"
    t.integer  "cpu_cores"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "os_release"
    t.string   "name"
    t.string   "proxy"
    t.string   "username",         default: "root"
    t.integer  "ram_bytes"
    t.integer  "disk_space_bytes"
  end

  create_table "package_updates", force: :cascade do |t|
    t.integer  "node_id"
    t.integer  "package_id"
    t.boolean  "applied"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "action_id"
  end

  create_table "packages", force: :cascade do |t|
    t.string   "name"
    t.string   "version"
    t.text     "information"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "security"
  end

  create_table "scripts", force: :cascade do |t|
    t.string   "name"
    t.integer  "replaced_by"
    t.string   "interpreter"
    t.integer  "timeout"
    t.text     "content"
    t.binary   "file_1"
    t.binary   "file_2"
    t.binary   "file_3"
    t.binary   "file_4"
    t.binary   "file_5"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "deleted",         default: false
    t.string   "file_1_filename"
    t.string   "file_2_filename"
    t.string   "file_3_filename"
    t.string   "file_4_filename"
    t.string   "file_5_filename"
    t.boolean  "sudo",            default: false
  end

  create_table "settings", force: :cascade do |t|
    t.string   "name"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statistics", force: :cascade do |t|
    t.integer  "node_id"
    t.string   "uptime"
    t.float    "load_percentage"
    t.integer  "free_memory_gb"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "free_disk_gb"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "password_hash"
    t.string   "password_salt"
    t.string   "name"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
  end

end
