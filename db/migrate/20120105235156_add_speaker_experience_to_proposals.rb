class AddSpeakerExperienceToProposals < ActiveRecord::Migration
  def self.up
    add_column :proposals, :speaking_experience, :text
  end

  def self.down
    remove_column :proposals, :speaking_experience
  end
end
