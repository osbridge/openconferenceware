class DropTimestampsFromProposalsUsers < ActiveRecord::Migration
  def change
    remove_column :proposals_users, :created_at, :datetime
    remove_column :proposals_users, :updated_at, :datetime
  end
end
