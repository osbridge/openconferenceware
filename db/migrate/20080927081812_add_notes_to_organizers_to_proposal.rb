class AddNotesToOrganizersToProposal < ActiveRecord::Migration
  def self.up
    add_column :proposals, :note_to_organizers, :text
  end

  def self.down
    remove_column :proposals, :note_to_organizers
  end
end
