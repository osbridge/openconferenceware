class CreateOpenConferenceWareUsers < ActiveRecord::Migration
  def change
    create_table :open_conference_ware_users do |t|
      t.string   "email"
      t.string   "salt",               limit: 40
      t.boolean  "admin",                           default: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "affiliation",        limit: 128
      t.text     "biography"
      t.string   "website",            limit: 1024
      t.boolean  "complete_profile"
      t.string   "photo_file_name"
      t.string   "photo_content_type"
      t.integer  "photo_file_size"
      t.string   "first_name"
      t.string   "last_name"
      t.string   "blog_url"
      t.string   "identica"
      t.string   "twitter"
      t.boolean  "selector",                        default: false
    end
  end
end
