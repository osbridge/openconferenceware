# == Schema Information
# Schema version: 20090316010807
#
# Table name: events
#
#  id                        :integer         not null, primary key
#  title                     :string(255)
#  deadline                  :datetime
#  open_text                 :text
#  closed_text               :text
#  created_at                :datetime
#  updated_at                :datetime
#  proposal_status_published :boolean         not null
#

class Event < ActiveRecord::Base
  # Mixins
  ### Provide cached Snippet.lookup(id) method.
  include CacheLookupsMixin
  cache_lookups_for :id, :order => 'deadline desc'

  # Associations
  has_many :proposals, :order => 'submitted_at desc'
  has_many :tracks, :order => 'title asc'
  has_many :session_types
  has_many :rooms

  # Validations
  validates_presence_of \
    :id,
    :title,
    :deadline,
    :open_text,
    :closed_text

  # Is this event accepting proposals?
  def accepting_proposals?
    return Time.now < (self.deadline || Time.at(0))
  end

  EVENT_CURRENT_ID_SNIPPET = "event_current_id"
  EVENT_CURRENT_CACHE_KEY = "event_current"

  # Return the current Event. Determines which event to return by checking to
  # see if a snippet says which is current, else tries to return the event
  # with the latest deadline, else returns a nil.
  def self.current
    return RAILS_CACHE.fetch_object(EVENT_CURRENT_CACHE_KEY) do
      self.current_by_snippet() || self.current_by_deadline()
    end
  end

  # Return current event by looking it up in a snippet.
  def self.current_by_snippet
    if snippet = Snippet.lookup(EVENT_CURRENT_ID_SNIPPET)
      return self.lookup(snippet.value)
    else
      return nil
    end
  end

  # Return current event by finding it by deadline.
  def self.current_by_deadline
    return self.find(:first, :order => 'deadline desc')
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
    return RAILS_CACHE.fetch_object("proposals_for_event_#{self.id}") do
      self.proposals
    end
  end
end
