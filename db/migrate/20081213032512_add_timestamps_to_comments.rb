class AddTimestampsToComments < ActiveRecord::Migration
  def self.up
    add_timestamps :comments

    Comment.reset_column_information

    puts "Setting all comments for latest event to current time"
    if latest_event = Event.find(:first, :order => "deadline desc")
      Comment.find(:all, :readonly => false, :joins => {:proposal => :event}, :conditions => ['events.id = ?', latest_event.id]).each do |t|
        t.update_attributes(:updated_at => Time.now, :created_at => Time.now)
      end
    end
  end

  def self.down
    remove_timestamps :comments
  end
end
