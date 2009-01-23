class CreateSessionTypes < ActiveRecord::Migration
  def self.up
    create_table :session_types do |t|
      t.string :title
      t.text :description
      t.integer :duration
      t.belongs_to :event
      t.timestamps
    end
  end

  def self.down
    drop_table :session_types
  end
end
