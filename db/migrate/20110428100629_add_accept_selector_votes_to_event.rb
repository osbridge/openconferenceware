class AddAcceptSelectorVotesToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :accept_selector_votes, :boolean, :default => false
  end

  def self.down
    remove_column :events, :accept_selector_votes
  end
end
