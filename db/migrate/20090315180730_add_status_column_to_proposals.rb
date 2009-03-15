class AddStatusColumnToProposals < ActiveRecord::Migration
  def self.up
    add_column :proposals, :status, :string
  end

  def self.down
    remove_column :proposals, :status
  end
end
