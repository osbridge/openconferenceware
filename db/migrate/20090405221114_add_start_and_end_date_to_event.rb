class AddStartAndEndDateToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :start_date, :datetime
    add_column :events, :end_date, :datetime
  end

  def self.down
    remove_column :events, :end_date
    remove_column :events, :start_date
  end
end
