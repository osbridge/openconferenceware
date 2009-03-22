class AddSessionTextToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :session_text, :text
  end

  def self.down
    remove_column :events, :session_text
  end
end
