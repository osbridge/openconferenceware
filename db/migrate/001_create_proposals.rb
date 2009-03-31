class CreateProposals < ActiveRecord::Migration
  def self.up
    create_table :proposals do |t|
      t.integer :user_id
      t.string :presenter
      t.string :affiliation
      t.string :email
      t.string :url
      t.text :bio
      t.string :title
      t.string :description
      t.boolean :publish, :default => false
      t.boolean :agreement, :default => true # Needed for #validates_acceptance_of

      t.timestamps
    end
  end

  def self.down
    drop_table :proposals
  end
end
