class AddTracksTextToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :tracks_text, :text
  end

  def self.down
    remove_column :events, :tracks_text
  end
end
