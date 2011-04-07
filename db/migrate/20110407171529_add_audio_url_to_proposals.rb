class AddAudioUrlToProposals < ActiveRecord::Migration
  def self.up
    add_column :proposals, :audio_url, :string
  end

  def self.down
    remove_column :proposals, :audio_url
  end
end
