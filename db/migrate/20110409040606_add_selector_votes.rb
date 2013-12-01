class AddSelectorVotes < ActiveRecord::Migration
  def self.up
    create_table :selector_votes do |t|
      t.integer :user_id, null: false
      t.integer :proposal_id, null: false
      t.integer :rating, null: false
      t.text :comment
    end
  end

  def self.down
    drop_table :selector_votes
  end
end
