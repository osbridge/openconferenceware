class AddEventProposalComments < ActiveRecord::Migration
  def self.up
    add_column :events, :accepting_proposal_comments, :boolean, :default => false
  end

  def self.down
    remove_column :events, :accepting_proposal_comments
  end
end
