class CreateOpenConferenceWareAuthentications < ActiveRecord::Migration
  def change
    create_table :open_conference_ware_authentications do |t|
      t.integer  "user_id"
      t.string   "provider"
      t.string   "uid"
      t.string   "name"
      t.string   "email"
      t.text     "info"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
