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

ActiveRecord::Schema.define(version: 20160303103331) do

  create_table "activities", force: :cascade do |t|
    t.string   "action",         limit: 255
    t.string   "trackable_type", limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.uuid     "trackable_id",   limit: 16
    t.uuid     "user_id",        limit: 16
  end

  add_index "activities", ["trackable_id", "trackable_type"], name: "a_trackables", using: :btree

  create_table "blocks", force: :cascade do |t|
    t.uuid     "user_id",        limit: 16
    t.uuid     "blockable_id",   limit: 16
    t.string   "blockable_type", limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "blocks", ["blockable_id", "blockable_type"], name: "b_blockables", using: :btree

  create_table "comments", force: :cascade do |t|
    t.string   "title",            limit: 50,    default: ""
    t.text     "comment",          limit: 65535
    t.uuid     "commentable_id",   limit: 16
    t.string   "commentable_type", limit: 255
    t.uuid     "user_id",          limit: 16
    t.string   "user_image",       limit: 255
    t.string   "role",             limit: 255,   default: "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
  add_index "comments", ["commentable_type"], name: "index_comments_on_commentable_type", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  add_index "delayed_jobs", ["queue"], name: "delayed_jobs_queue", using: :btree

  create_table "follow_queues", force: :cascade do |t|
    t.string   "follower_type",   limit: 255
    t.uuid     "follower_id",     limit: 16
    t.string   "followable_type", limit: 255
    t.uuid     "followable_id",   limit: 16
    t.boolean  "approved",                    default: false
    t.datetime "created_at"
  end

  add_index "follow_queues", ["followable_id", "followable_type"], name: "fk_followables", using: :btree
  add_index "follow_queues", ["follower_id", "follower_type"], name: "fk_follows", using: :btree

  create_table "follows", force: :cascade do |t|
    t.string   "follower_type",   limit: 255
    t.uuid     "follower_id",     limit: 16
    t.string   "followable_type", limit: 255
    t.uuid     "followable_id",   limit: 16
    t.datetime "created_at"
  end

  add_index "follows", ["followable_id", "followable_type"], name: "fk_followables", using: :btree
  add_index "follows", ["follower_id", "follower_type"], name: "fk_follows", using: :btree

  create_table "group_timelines", force: :cascade do |t|
    t.uuid     "timeline_id",  limit: 16
    t.uuid     "user_id",      limit: 16
    t.string   "user_name",    limit: 255
    t.text     "participants", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_timelines", ["timeline_id"], name: "index_group_timelines_on_timeline_id", using: :btree

  create_table "likes", force: :cascade do |t|
    t.string   "liker_type",    limit: 255
    t.uuid     "liker_id",      limit: 16
    t.string   "likeable_type", limit: 255
    t.uuid     "likeable_id",   limit: 16
    t.datetime "created_at"
  end

  add_index "likes", ["likeable_id", "likeable_type"], name: "fk_likeables", using: :btree
  add_index "likes", ["liker_id", "liker_type"], name: "fk_likes", using: :btree

  create_table "mentions", force: :cascade do |t|
    t.string   "mentioner_type",   limit: 255
    t.uuid     "mentioner_id",     limit: 16
    t.string   "mentionable_type", limit: 255
    t.uuid     "mentionable_id",   limit: 16
    t.datetime "created_at"
  end

  add_index "mentions", ["mentionable_id", "mentionable_type"], name: "fk_mentionables", using: :btree
  add_index "mentions", ["mentioner_id", "mentioner_type"], name: "fk_mentions", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.uuid     "user_id",      limit: 16
    t.string   "notification", limit: 255
    t.text     "payload",      limit: 65535
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "notifications", ["user_id"], name: "user_notifications", using: :btree

  create_table "timelines", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.uuid     "user_id",         limit: 16
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "likers_count",    limit: 4,   default: 0
    t.integer  "followers_count", limit: 4,   default: 0
    t.integer  "comments_count",  limit: 4,   default: 0
    t.boolean  "group_timeline",              default: false
    t.string   "description",     limit: 255, default: ""
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",                    limit: 255
    t.string   "email",                   limit: 255
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.string   "external_id",             limit: 255
    t.boolean  "timelines_public",                    default: true
    t.boolean  "approve_followers",                   default: false
    t.integer  "followers_count",         limit: 4,   default: 0
    t.integer  "allowed_timelines_count", limit: 4,   default: 2
    t.integer  "likers_count",            limit: 4,   default: 0
    t.integer  "followees_count",         limit: 4,   default: 0
  end

  create_table "videos", force: :cascade do |t|
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "video_file_name",    limit: 255
    t.string   "video_content_type", limit: 255
    t.integer  "video_file_size",    limit: 4
    t.datetime "video_updated_at"
    t.uuid     "timeline_id",        limit: 16
    t.float    "duration",           limit: 24
    t.string   "overlay_text",       limit: 250
    t.float    "overlay_position",   limit: 24
    t.integer  "overlay_size",       limit: 4
    t.string   "overlay_color",      limit: 255
    t.integer  "comments_count",     limit: 4,   default: 0
  end

  add_index "videos", ["timeline_id"], name: "video_timelines", using: :btree

end
