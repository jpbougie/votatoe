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

ActiveRecord::Schema.define(:version => 20100618190521) do

  create_table "accounts", :force => true do |t|
    t.integer  "user_id"
    t.string   "token"
    t.string   "secret"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "polls", :force => true do |t|
    t.integer  "user_id"
    t.string   "text"
    t.string   "status_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "last_seen_id"
  end

  add_index "polls", ["status_id"], :name => "index_polls_on_status_id", :unique => true

  create_table "tweets", :force => true do |t|
    t.string   "status_id"
    t.text     "payload"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "twitter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["twitter_id"], :name => "index_users_on_twitter_id", :unique => true

  create_table "votes", :force => true do |t|
    t.integer  "poll_id"
    t.string   "status_id"
    t.string   "author"
    t.string   "choice"
    t.string   "location"
    t.string   "agent"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "text"
    t.string   "username"
  end

  add_index "votes", ["poll_id", "author"], :name => "index_votes_on_poll_id_and_author", :unique => true
  add_index "votes", ["status_id"], :name => "index_votes_on_status_id", :unique => true

end
