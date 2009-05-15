class AddSchedulePublishedSwitchToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :schedule_published, :boolean, :default => false
  end

  def self.down
    remove_column :events, :schedule_published
  end
end
