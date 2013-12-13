class CreateProposalsUsersJoinTable < ActiveRecord::Migration
  def change
    create_table :open_conference_ware_proposals_users, :id => false do |t|
      t.integer :proposal_id
      t.integer :user_id
    end

    add_index "open_conference_ware_proposals_users", ["proposal_id"]
    add_index "open_conference_ware_proposals_users", ["user_id"]
  end
end
