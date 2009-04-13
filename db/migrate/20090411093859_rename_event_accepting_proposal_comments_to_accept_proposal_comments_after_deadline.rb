class RenameEventAcceptingProposalCommentsToAcceptProposalCommentsAfterDeadline < ActiveRecord::Migration
  def self.up
    rename_column :events, :accepting_proposal_comments, :accept_proposal_comments_after_deadline
  end

  def self.down
    rename_column :events, :accept_proposal_comments_after_deadline, :accepting_proposal_comments
  end
end
