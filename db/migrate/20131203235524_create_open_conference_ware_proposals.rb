class CreateOpenConferenceWareProposals < ActiveRecord::Migration
  def change
    create_table :open_conference_ware_proposals do |t|
      t.integer  "user_id"
      t.string   "presenter"
      t.string   "affiliation"
      t.string   "email"
      t.string   "website"
      t.text     "biography"
      t.string   "title"
      t.text     "description"
      t.boolean  "agreement",           default: true
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "event_id"
      t.datetime "submitted_at"
      t.text     "note_to_organizers"
      t.text     "excerpt"
      t.integer  "track_id"
      t.integer  "session_type_id"
      t.string   "status",              default: "proposed", null: false
      t.integer  "room_id"
      t.datetime "start_time"
      t.string   "audio_url"
      t.text     "speaking_experience"
      t.string   "audience_level"
      t.datetime "notified_at"
    end

    add_index "open_conference_ware_proposals", ["event_id"], name: "index_proposals_on_event_id", using: :btree
    add_index "open_conference_ware_proposals", ["room_id"], name: "index_proposals_on_room_id", using: :btree
    add_index "open_conference_ware_proposals", ["submitted_at"], name: "index_proposals_on_submitted_at", using: :btree
    add_index "open_conference_ware_proposals", ["track_id"], name: "index_proposals_on_track_id", using: :btree
    add_index "open_conference_ware_proposals", ["user_id"], name: "index_proposals_on_user_id", using: :btree
  end
end
