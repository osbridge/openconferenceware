class DropAuthFieldsFromUser < ActiveRecord::Migration
  def up
    remove_column :users, :login
    remove_column :users, :crypted_password
    remove_column :users, :remember_token
    remove_column :users, :remember_token_expires_at
    remove_column :users, :using_openid
  end
end
