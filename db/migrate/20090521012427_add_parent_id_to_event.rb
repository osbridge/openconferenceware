class AddParentIdToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :parent_id, :integer
  end

  def self.down
    remove_column :events, :parent_id
  end
end
