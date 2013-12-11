class CreateOpenConferenceWareTracks < ActiveRecord::Migration
  def change
    create_table :open_conference_ware_tracks do |t|
      t.string   "title"
      t.text     "description"
      t.string   "color"
      t.integer  "event_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "excerpt"
    end

    add_index "open_conference_ware_tracks", ["event_id"], name: "index_tracks_on_event_id", using: :btree
  end
end
