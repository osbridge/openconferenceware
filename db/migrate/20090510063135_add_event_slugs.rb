class AddEventSlugs < ActiveRecord::Migration
  def self.up
    add_column :events, :slug, :string
    add_index :events, :slug
    Event.all.each do |event|
      event.slug = event.id
      event.save!
    end
  end

  def self.down
    remove_index :events, :slug
    remove_column :events, :slug
  end
end
