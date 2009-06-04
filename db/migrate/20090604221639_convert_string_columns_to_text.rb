class ConvertStringColumnsToText < ActiveRecord::Migration
  def self.up
    change_column :proposals, :description, :text
    change_column :schedule_items, :excerpt, :text
    change_column :schedule_items, :description, :text
    change_column :snippets, :description, :text
    change_column :tracks, :description, :text
  end

  def self.down
    change_column :proposals, :description, :string
    change_column :schedule_items, :excerpt, :string
    change_column :schedule_items, :description, :string
    change_column :snippets, :description, :string
    change_column :tracks, :description, :string
  end
end

__END__

# Add to database.yml
old:
  adapter: sqlite3
  timeout: 5000
  database: db/development.sqlite3

class OldProposal < Proposal
  establish_connection "old"
end
OldProposal.all.each do |old|
  current = Proposal.find(old.id)
  current.description = old.description
  current.save!
end

class OldScheduleItem < ScheduleItem
  establish_connection "old"
end
OldScheduleItem.all.each do |old|
  current = ScheduleItem.find(old.id)
  current.description = old.description
  current.excerpt = old.excerpt
  current.save!
end

class OldSnippet < Snippet
  establish_connection "old"
end
OldSnippet.all.each do |old|
  current = Snippet.find(old.id)
  current.description = old.description
  current.save!
end

class OldTrack < Track
  establish_connection "old"
end
OldTrack.all.each do |old|
  current = Track.find(old.id)
  current.description = old.description
  current.save!
end

