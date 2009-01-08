class CreateSnippets < ActiveRecord::Migration
  def self.up
    create_table :snippets do |t|
      t.string :slug, :null => false
      t.string :description, :null => false
      t.text :content
      t.integer :value
      t.boolean :public, :default => true

      t.timestamps
    end

    add_index :snippets, :slug, :unique => true
  end

  def self.down
    drop_table :snippets
  end
end
