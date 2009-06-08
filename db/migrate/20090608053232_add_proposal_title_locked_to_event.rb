class AddProposalTitleLockedToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :proposal_titles_locked, :boolean, :default => false
  end

  def self.down
    remove_column :events, :proposal_titles_locked
  end
end
