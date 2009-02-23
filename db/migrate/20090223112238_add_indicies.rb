class AddIndicies < ActiveRecord::Migration
  def self.up
    add_index :comments, :proposal_id
    add_index :proposals, :submitted_at
    add_index :proposals, :track_id
    add_index :proposals, :user_id
    add_index :proposals_users, :proposal_id
    add_index :proposals_users, :user_id
    add_index :tracks, :event_id
    add_index :session_types, :event_id
  end

  def self.down
    remove_index :session_types, :event_id
    remove_index :tracks, :event_id
    remove_index :proposals_users, :user_id
    remove_index :proposals_users, :proposal_id
    remove_index :proposals, :user_id
    remove_index :proposals, :track_id
    remove_index :proposals, :submitted_at
    remove_index :comments, :proposal_id
  end
end
