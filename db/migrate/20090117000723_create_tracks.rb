class CreateTracks < ActiveRecord::Migration
  def self.up
    create_table :tracks do |t|
      t.string :title
      t.string :description
      t.string :color

      t.integer :event_id

      t.timestamps
    end

    add_column :proposals, :track_id, :integer
  end

  def self.down
    drop_table :tracks
    remove_column :proposals, :track_id
  end
end
