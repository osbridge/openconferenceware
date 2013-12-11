class CreateOpenConferenceWareSelectorVotes < ActiveRecord::Migration
  def change
    create_table :open_conference_ware_selector_votes do |t|
      t.integer "user_id",     null: false
      t.integer "proposal_id", null: false
      t.integer "rating",      null: false
      t.text    "comment"
    end
  end
end
