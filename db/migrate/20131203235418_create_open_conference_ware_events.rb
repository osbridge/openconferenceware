class CreateOpenConferenceWareEvents < ActiveRecord::Migration
  def change
    create_table :open_conference_ware_events do |t|
      t.string   "title"
      t.datetime "deadline"
      t.text     "open_text"
      t.text     "closed_text"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "proposal_status_published",               default: false, null: false
      t.text     "session_text"
      t.text     "tracks_text"
      t.datetime "start_date"
      t.datetime "end_date"
      t.boolean  "accept_proposal_comments_after_deadline", default: false
      t.string   "slug"
      t.boolean  "schedule_published",                      default: false
      t.integer  "parent_id"
      t.boolean  "proposal_titles_locked",                  default: false
      t.boolean  "accept_selector_votes",                   default: false
      t.boolean  "show_proposal_confirmation_controls",     default: false
    end

    add_index "open_conference_ware_events", ["slug"]
  end
end
