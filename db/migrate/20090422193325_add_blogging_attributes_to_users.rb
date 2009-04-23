class AddBloggingAttributesToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :blog_url, :string, :length => 128
    add_column :users, :identica, :string, :length => 20
    add_column :users, :twitter, :string, :length => 20
  end

  def self.down
    remove_column :users, :blog_url
    remove_column :users, :identica
    remove_column :users, :twitter
  end
end
