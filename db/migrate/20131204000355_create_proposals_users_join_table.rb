class CreateProposalsUsersJoinTable < ActiveRecord::Migration
  def change
    create_table :open_conference_ware_proposals_users, :id => false do |t|
      t.integer :proposal_id
      t.integer :user_id
    end
  end
end
