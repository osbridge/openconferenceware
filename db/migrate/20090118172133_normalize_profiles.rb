class NormalizeProfiles < ActiveRecord::Migration
  def self.up
    rename_column :proposals, :bio, :biography
    rename_column :proposals, :url, :website
    remove_column :proposals, :publish
  end

  def self.down
    add_column :proposals, :publish, :boolean
    rename_column :proposals, :biography, :bio
    rename_column :proposals, :website, :url
  end
end
