# == Schema Information
# Schema version: 20090616061006
#
# Table name: events
#
#  id                                      :integer(4)      not null, primary key
#  title                                   :string(255)     
#  deadline                                :datetime        
#  open_text                               :text            
#  closed_text                             :text            
#  created_at                              :datetime        
#  updated_at                              :datetime        
#  proposal_status_published               :boolean(1)      not null
#  session_text                            :text            
#  tracks_text                             :text            
#  start_date                              :datetime        
#  end_date                                :datetime        
#  accept_proposal_comments_after_deadline :boolean(1)      
#  slug                                    :string(255)     
#  schedule_published                      :boolean(1)      
#  parent_id                               :integer(4)      
#  proposal_titles_locked                  :boolean(1)      
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
  
  # Determines if the event is currently taking place.
  def underway?
    self.start_date && self.end_date && (self.start_date..self.end_date).include?(Time.zone.now)
  end

  EVENT_CURRENT_CACHE_KEY = "event_current"

  # Return the current Event. Determines which event to return by checking to
  # see if a snippet says which is current, else tries to return the event
  # with the latest deadline, else returns a nil.
  def self.current
    return self.fetch_object(EVENT_CURRENT_CACHE_KEY) do
      if record = (self.current_by_settings || self.current_by_deadline)
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

  # Return current event by finding it through SETTINGS global.
  # TODO Get the current event from an attribute in the Site object.
  def self.current_by_settings
    if slug = SETTINGS.current_event_slug
      begin
        return Event.find_by_slug(slug)
      rescue ActiveRecord::RecordNotFound
        return nil
      end
    else
      return nil
    end
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

  # Return an array of the Event's ScheduleItems and Proposal sessions that
  # have been scheduled and given a room location.
  def calendar_items
    return \
      (self.schedule_published? \
        ? self.proposals.confirmed.scheduled.located.find(:all, :include => [:users, :room, :session_type, {:track => :event}]) \
        : []) + \
      self.schedule_items.find(:all, :include => [:room]) + \
      self.children.map(&:calendar_items).flatten
  end
  
  # Return list of people that submitted to this event.
  def users
    return User.submitted_to(self)
  end
  
  # Return list of speakers for this event.
  def speakers
    return User.speaking_at(self)
  end

  # Return records for this event that are of the given +kind+ (e.g.,
  # :proposals or :sessions).
  def populated_proposals(kind=:proposals)
    case kind
    when :proposals
      return self.proposals.populated
    when :sessions
      return self.proposals.populated.confirmed
    else
      raise ArgumentError, "Unknown kind: #{kind}"
    end
  end

  # Return other Event objects.
  def other_events
    return self.class.find(:all, :order => "title asc", :select => "id, title").reject{|event| event == self}
  end

  # Return array of Rooms for this event and its parent event.
  def rooms_inherit
    return [self.parent.ergo.rooms, self.rooms].flatten.compact.sort_by(&:name)
  end

  # Return array of Tracks for this event, its parent, and its siblings.
  def tracks_combined
    return [self.tracks_descend, self.parent.ergo.tracks_descend].flatten.compact.uniq.sort_by(&:title)
  end
  
  # Return array of Tracks for this event and its children.
  def tracks_descend
    return (self.tracks + self.children.map(&:tracks)).flatten.uniq.sort_by(&:title)
  end

  # Return start_time for either self or parent Event.
  def start_date
    return self.parent_id ? self.parent.start_date : self.read_attribute(:start_date)
  end

  # Return end_time for either self or parent Event.
  def end_date
    return self.parent_id ? self.parent.end_date : self.read_attribute(:end_date)
  end

  # Return the parent event or this Event.
  def parent_or_self
    return self.parent || self
  end
end
