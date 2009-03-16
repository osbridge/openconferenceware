class CreateRooms < ActiveRecord::Migration
  def self.up
    create_table :rooms do |t|
      t.string :name, :null => false
      t.integer :capacity
      t.string :size, :seating_configuration
      t.text :description
      t.belongs_to :event

      t.timestamps
    end
  end

  def self.down
    drop_table :rooms
  end
end
