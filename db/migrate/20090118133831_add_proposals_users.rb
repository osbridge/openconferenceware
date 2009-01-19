class AddProposalsUsers < ActiveRecord::Migration
  def self.up
    create_table :proposals_users, :id => false do |t|
      t.integer :proposal_id
      t.integer :user_id

      t.timestamps
    end

    Proposal.find(:all).each do |proposal|
      ProposalsUser.create!(:proposal_id => proposal.id, :user_id => proposal.user_id)
    end
  end

  def self.down
    drop_table :proposals_users
  end
end
