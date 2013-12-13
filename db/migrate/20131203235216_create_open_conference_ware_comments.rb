class CreateOpenConferenceWareComments < ActiveRecord::Migration
  def change
    create_table :open_conference_ware_comments do |t|
      t.string   "name"
      t.string   "email"
      t.text     "message"
      t.integer  "proposal_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "open_conference_ware_comments", ["proposal_id"]
  end
end
