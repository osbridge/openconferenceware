# == Schema Information
# Schema version: 20090521012427
#
# Table name: events
#
#  id                                      :integer         not null, primary key
#  title                                   :string(255)     
#  deadline                                :datetime        
#  open_text                               :text            
#  closed_text                             :text            
#  created_at                              :datetime        
#  updated_at                              :datetime        
#  proposal_status_published               :boolean         not null
#  session_text                            :text            
#  tracks_text                             :text            
#  start_date                              :datetime        
#  end_date                                :datetime        
#  accept_proposal_comments_after_deadline :boolean         
#  schedule_published                      :boolean
#  slug                                    :string(255)
#  parent_id                               :integer
#

class Event < ActiveRecord::Base
  # Mixins
  ### Provide cached Snippet.lookup(id) method.
  include CacheLookupsMixin
  include SimpleSlugMixin

  cache_lookups_for :slug, :order => 'deadline desc', :include => [:tracks, :rooms]

  # Associations
  has_many :proposals, :order => 'submitted_at desc'
  has_many :tracks, :order => 'title asc'
  has_many :session_types
  has_many :rooms
  has_many :schedule_items
  has_many :children, :class_name => 'Event', :foreign_key => 'parent_id'
  belongs_to :parent, :class_name => 'Event', :foreign_key => 'parent_id'

  # Validations
  validates_presence_of \
    :slug,
    :title,
    :deadline,
    :open_text,
    :closed_text

  # Is this event accepting proposals?
  def accepting_proposals?
    return Time.now < (self.deadline || Time.at(0))
  end
  
  # Returns an array of the dates when this event is happening.
  def dates
    if self.start_date.nil? || self.end_date.nil?
      return []
    else
      return (self.start_date.to_date .. self.end_date.to_date).to_a
    end
  end
  
  # Formats this event's dates for use in a select form control.
  def dates_for_select
    return [['','']] + self.dates.map{|date| [date.strftime("%B %d, %Y"), date.strftime("%Y-%m-%d")]}
  end

  EVENT_CURRENT_CACHE_KEY = "event_current"

  # Return the current Event. Determines which event to return by checking to
  # see if a snippet says which is current, else tries to return the event
  # with the latest deadline, else returns a nil.
  def self.current
    return self.fetch_object(EVENT_CURRENT_CACHE_KEY) do
      if record = self.current_by_deadline
        self.lookup(record.slug)
      else
        nil
      end
    end
  end

  # Return current event by finding it by deadline.
  def self.current_by_deadline
    return Event.find(:first, :order => 'deadline desc')
  end

  # Delete the current cached event if it's present
  def self.expire_current
    RAILS_CACHE.delete(EVENT_CURRENT_CACHE_KEY)
  end

  # Override CacheLookupsMixin to expire more
  def self.expire_cache
    self.expire_current
    super
  end

  # Returns cached array of proposals for this event.
  def lookup_proposals
    self.fetch_object("proposals_for_event_#{self.id}") do
      self.proposals
    end
  end

  # Return an array of this Event's Proposals with their Tracks for use by proposals#stats.
  def proposals_for_stats
    return self.proposals.find(
      :all, 
      :order => "created_at", 
      :select => "proposals.id, proposals.track_id, proposals.created_at, proposals.submitted_at", 
      :include => [:track])
  end

  # Return an array of populated sessions for this event.
  def populated_sessions
    return self.proposals.populated.confirmed
  end

  # Return an array of populated proposals for this event.
  def populated_proposals
    return self.proposals.populated
  end

  # Return an array of the Event's ScheduleItems and Proposal sessions that
  # have been scheduled and given a room location.
  def calendar_items
    return \
      self.proposals.scheduled.located.find(:all, \
        :include => [:users, :room, :session_type, {:track => :event}]) + \
      self.schedule_items.find(:all, :include => [:room]) + \
      self.children.map(&:calendar_items).flatten
  end

end
