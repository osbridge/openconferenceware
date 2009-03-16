class AddRoomToProposals < ActiveRecord::Migration
  def self.up
    add_column :proposals, :room_id, :integer
    add_index :proposals, :room_id
  end

  def self.down
    remove_index :proposals, :room_id
    remove_column :proposals, :room_id
  end
end
