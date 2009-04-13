class AddExcerptToProposals < ActiveRecord::Migration
  def self.up
    add_column :proposals, :excerpt, :text
  end

  def self.down
    remove_column :proposals, :excerpt
  end
end
