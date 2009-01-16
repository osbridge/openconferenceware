class AddCompleteProfileToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :complete_profile, :boolean
  end

  def self.down
    remove_column :users, :complete_profile, :boolean
  end
end
