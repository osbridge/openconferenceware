# Preserve creation time of proposals in a separate column, because created_at
# can't survive a database reload. :(
class AddSubmittedAtToProposals < ActiveRecord::Migration
  def self.up
    add_column :proposals, :submitted_at, :datetime
    Proposal.reset_column_information

    proposals = Proposal.find(:all)
    say_with_time "Populated submitted_at columns in #{proposals.size} records..." do
      for proposal in proposals
        proposal.update_attribute(:submitted_at, proposal.created_at)
      end
    end
  end

  def self.down
    remove_column :proposals, :submitted_at
  end
end
