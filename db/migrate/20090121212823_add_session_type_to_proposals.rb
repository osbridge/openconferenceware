class AddSessionTypeToProposals < ActiveRecord::Migration
  def self.up
    add_column :proposals, :session_type_id, :integer
  end

  def self.down
    remove_column :proposals, :session_type_id
  end
end
