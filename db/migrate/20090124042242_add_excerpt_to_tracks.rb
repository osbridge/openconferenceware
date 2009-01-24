class AddExcerptToTracks < ActiveRecord::Migration
  def self.up
    add_column :tracks, :excerpt, :text
  end

  def self.down
    remove_column :tracks, :excerpt
  end
end
