class AddAudienceLevelToProposals < ActiveRecord::Migration
  def self.up
    add_column :proposals, :audience_level, :string
  end

  def self.down
    remove_column :proposals, :audience_level
  end
end
