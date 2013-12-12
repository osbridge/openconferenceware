class CreateOpenConferenceWareUserFavorites < ActiveRecord::Migration
  def change
    create_table :open_conference_ware_user_favorites do |t|
      t.integer  "user_id"
      t.integer  "proposal_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
