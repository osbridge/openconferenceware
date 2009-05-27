class AddUserFavorites < ActiveRecord::Migration
  def self.up
    create_table :user_favorites do |t|
      t.belongs_to :user
      t.belongs_to :proposal
      t.timestamps
    end
  end

  def self.down
    drop_table :users_favorite_proposals
  end
end
