class AddStartTimeToProposals < ActiveRecord::Migration
  def self.up
    add_column :proposals, :start_time, :datetime
  end

  def self.down
    remove_column :proposals, :start_time
  end
end