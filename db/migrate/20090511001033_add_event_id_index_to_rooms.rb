class AddEventIdIndexToRooms < ActiveRecord::Migration
  def self.up
    add_index :rooms, :event_id
  end

  def self.down
    remove_index :rooms, :event_id
  end
end
