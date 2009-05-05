class AddProfilesToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :affiliation, :string, :limit => 128
    add_column :users, :biography,   :text
    add_column :users, :website,     :string, :limit => 1024
  end

  def self.down
    remove_column :users, :affiliation
    remove_column :users, :biography
    remove_column :users, :website
  end
end
