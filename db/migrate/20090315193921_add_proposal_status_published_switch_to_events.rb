class AddProposalStatusPublishedSwitchToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :proposal_status_published, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :events, :proposal_status_published
  end
end
