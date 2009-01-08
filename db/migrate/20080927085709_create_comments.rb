class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.string  :name
      t.string  :email
      t.text    :message
      t.integer :proposal_id
    end
  end

  def self.down
    drop_table :comments
  end
end
