class AddNotifiedAtToProposals < ActiveRecord::Migration
  def self.up
    add_column :proposals, :notified_at, :datetime
  end

  def self.down
    remove_column :proposals, :notified_at
  end
end
