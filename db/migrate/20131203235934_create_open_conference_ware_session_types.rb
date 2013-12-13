class CreateOpenConferenceWareSessionTypes < ActiveRecord::Migration
  def change
    create_table :open_conference_ware_session_types do |t|
      t.string   "title"
      t.text     "description"
      t.integer  "duration"
      t.integer  "event_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "open_conference_ware_session_types", ["event_id"]
  end
end
