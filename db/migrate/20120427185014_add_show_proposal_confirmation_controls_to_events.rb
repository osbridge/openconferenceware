class AddShowProposalConfirmationControlsToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :show_proposal_confirmation_controls, :boolean, :default => false
  end

  def self.down
    remove_column :events, :show_proposal_confirmation_controls
  end
end
