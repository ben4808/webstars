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

ActiveRecord::Schema.define(version: 20130723010703) do

  create_table "constellations", force: true do |t|
    t.string "name"
    t.string "abbr"
  end

  create_table "hip_stars", force: true do |t|
    t.integer "hip"
    t.integer "hd"
    t.integer "constellation_id"
    t.decimal "ra_deg",           precision: 11, scale: 8
    t.decimal "dec_deg",          precision: 10, scale: 8
    t.decimal "mag",              precision: 4,  scale: 2
    t.string  "bayer"
    t.string  "flam"
    t.string  "gould"
    t.string  "name"
    t.boolean "is_common",                                 default: false, null: false
    t.string  "var_name"
  end

  create_table "ngcic_dsos", force: true do |t|
    t.string  "ngc"
    t.string  "ic"
    t.integer "obj_type_id"
    t.integer "constellation_id"
    t.decimal "ra_deg",           precision: 11, scale: 8
    t.decimal "dec_deg",          precision: 10, scale: 8
    t.decimal "mag",              precision: 4,  scale: 2
    t.decimal "size_maj",         precision: 6,  scale: 2
    t.decimal "size_min",         precision: 6,  scale: 2
    t.integer "pa"
    t.string  "name"
    t.string  "description"
    t.string  "other_ngc"
    t.string  "mess"
    t.string  "cald"
    t.string  "ugc"
    t.string  "mcg"
    t.string  "cgcg"
    t.string  "pgc"
    t.string  "arp"
    t.string  "eso"
    t.string  "pk"
    t.string  "ocl"
    t.string  "gcl"
  end

  create_table "obj_types", force: true do |t|
    t.string "name"
    t.string "abbr"
  end

  create_table "other_dsos", force: true do |t|
    t.string  "name"
    t.integer "obj_type_id"
    t.decimal "ra_deg",      precision: 11, scale: 8
    t.decimal "dec_deg",     precision: 10, scale: 8
    t.decimal "mag",         precision: 4,  scale: 2
  end

  create_table "stars", force: true do |t|
    t.integer "hd"
    t.integer "tyc1"
    t.integer "tyc2"
    t.integer "tyc3"
    t.decimal "ra_deg",  precision: 11, scale: 8
    t.decimal "dec_deg", precision: 10, scale: 8
    t.decimal "mag",     precision: 4,  scale: 2
  end

end
