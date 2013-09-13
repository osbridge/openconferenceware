class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :title
      t.datetime :deadline
      t.text :open_text
      t.text :closed_text

      t.timestamps
    end
    add_index :events, :id, :unique => true

    add_column :proposals, :event_id, :integer
    add_index  :proposals, :event_id
  end

  def self.down
    remove_index  :proposals, :event_id
    remove_column :proposals, :event_id

    remove_index :events, :id, :unique => true

    drop_table :events
  end
end
