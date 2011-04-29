class AddSelectorToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :selector, :boolean, :default => false
  end

  def self.down
    remove_column :users, :selector
  end
end
