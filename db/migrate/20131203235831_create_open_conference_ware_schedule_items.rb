class CreateOpenConferenceWareScheduleItems < ActiveRecord::Migration
  def change
    create_table :open_conference_ware_schedule_items do |t|
      t.string   "title"
      t.text     "excerpt"
      t.text     "description"
      t.datetime "start_time"
      t.integer  "duration"
      t.integer  "event_id"
      t.integer  "room_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "open_conference_ware_schedule_items", ["event_id"], name: "index_schedule_items_on_event_id", using: :btree
    add_index "open_conference_ware_schedule_items", ["room_id"], name: "index_schedule_items_on_room_id", using: :btree
  end
end
