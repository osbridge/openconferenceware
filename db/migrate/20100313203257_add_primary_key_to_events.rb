class AddPrimaryKeyToEvents < ActiveRecord::Migration
  def self.up
    change_column :events, :id, :primary_key
  end

  def self.down
  end
end
