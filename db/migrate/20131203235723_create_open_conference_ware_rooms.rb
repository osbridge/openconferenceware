class CreateOpenConferenceWareRooms < ActiveRecord::Migration
  def change
    create_table :open_conference_ware_rooms do |t|
      t.string   "name",                  null: false
      t.integer  "capacity"
      t.string   "size"
      t.string   "seating_configuration"
      t.text     "description"
      t.integer  "event_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "image_file_name"
      t.string   "image_content_type"
      t.integer  "image_file_size"
      t.datetime "image_updated_at"
    end

    add_index "open_conference_ware_rooms", ["event_id"]
  end
end
