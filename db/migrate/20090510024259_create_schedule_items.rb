class CreateScheduleItems < ActiveRecord::Migration
  def self.up
    create_table :schedule_items do |t|
      t.string :title, :excerpt, :description
      t.datetime :start_time
      t.integer :duration
      t.belongs_to :event, :room
      t.timestamps
    end

    add_index :schedule_items, :event_id
    add_index :schedule_items, :room_id
  end

  def self.down
    drop_table :schedule_items
  end
end
