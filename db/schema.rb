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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130412203625) do

  create_table "channels", :force => true do |t|
    t.string   "name"
    t.string   "search"
    t.string   "access_token"
    t.string   "access_token_secret"
    t.string   "last_tweet_id"
    t.datetime "searched_at"
    t.integer  "interval"
    t.boolean  "running",                :default => false
    t.boolean  "default_approved_state", :default => true
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.integer  "video_limit"
    t.integer  "user_id"
    t.text     "custom_css"
    t.string   "ga_tag"
    t.string   "subdomain"
    t.string   "password_digest"
    t.boolean  "default_mute"
    t.datetime "last_visited_at"
    t.string   "last_search_status"
  end

  add_index "channels", ["subdomain"], :name => "index_channels_on_subdomain", :unique => true
  add_index "channels", ["user_id"], :name => "index_channels_on_user_id"

  create_table "plans", :force => true do |t|
    t.string   "name"
    t.integer  "channels",                                              :default => 0,    :null => false
    t.boolean  "embed"
    t.string   "fastspring_reference"
    t.datetime "created_at",                                                              :null => false
    t.datetime "updated_at",                                                              :null => false
    t.boolean  "subscribable",                                          :default => true
    t.integer  "position"
    t.string   "billing_period"
    t.decimal  "price",                  :precision => 10, :scale => 2, :default => 0.0
    t.string   "usage"
    t.string   "support"
    t.boolean  "custom_subdomain"
    t.boolean  "branding"
    t.boolean  "moderation"
    t.boolean  "password_channel"
    t.boolean  "your_own_domain"
    t.boolean  "feature_prioritisation"
    t.boolean  "mobile_optimised"
    t.string   "description"
  end

  create_table "rails_admin_histories", :force => true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      :limit => 2
    t.integer  "year",       :limit => 8
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_rails_admin_histories"

  create_table "subscriptions", :force => true do |t|
    t.integer  "user_id"
    t.string   "reference"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.date     "end_date"
    t.date     "next_period_date"
    t.string   "status"
    t.string   "status_reason"
    t.string   "currency"
    t.decimal  "total_price",      :precision => 8, :scale => 2
  end

  add_index "subscriptions", ["reference"], :name => "index_subscriptions_on_reference", :unique => true
  add_index "subscriptions", ["user_id"], :name => "index_subscriptions_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "uid"
    t.string   "access_token"
    t.string   "access_token_secret"
    t.boolean  "super_admin",         :default => false
    t.string   "nickname"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "email",               :default => "",    :null => false
    t.string   "encrypted_password",  :default => "",    :null => false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "provider"
    t.integer  "plan_id"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["plan_id"], :name => "index_users_on_plan_id"
  add_index "users", ["uid"], :name => "index_users_on_uid", :unique => true

  create_table "videos", :force => true do |t|
    t.integer  "channel_id"
    t.string   "video_url"
    t.string   "vine_url"
    t.text     "tweet"
    t.boolean  "approved"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.boolean  "moderated",     :default => false
    t.string   "thumbnail_url"
  end

  add_index "videos", ["channel_id", "vine_url"], :name => "index_videos_on_channel_id_and_vine_url", :unique => true
  add_index "videos", ["channel_id"], :name => "index_videos_on_channel_id"

end
