# == Schema Information
# Schema version: 20090616061006
#
# Table name: proposals
#
#  id                 :integer(4)      not null, primary key
#  user_id            :integer(4)      
#  presenter          :string(255)     
#  affiliation        :string(255)     
#  email              :string(255)     
#  website            :string(255)     
#  biography          :text            
#  title              :string(255)     
#  description        :text            
#  agreement          :boolean(1)      default(TRUE)
#  created_at         :datetime        
#  updated_at         :datetime        
#  event_id           :integer(4)      
#  submitted_at       :datetime        
#  note_to_organizers :text            
#  excerpt            :text            
#  track_id           :integer(4)      
#  session_type_id    :integer(4)      
#  status             :string(255)     default("proposed"), not null
#  room_id            :integer(4)      
#  start_time         :datetime        
#

class Proposal < ActiveRecord::Base
  # Provide ::validate_url_attribute
  include NormalizeUrlMixin

  # Provide ::event_tracks? and other methods for accessing SETTING
  include SettingsCheckersMixin

  # Provide ::lookup
  include CacheLookupsMixin

  # Provide ::overlaps?
  include ScheduleOverlapsMixin

  cache_lookups_for :id, :order => 'submitted_at desc', :include => [:event, :track, :room, :users]

  # Provide #tags
  acts_as_taggable_on :tags

  # Acts As State Machine
  include AASM

  aasm_column :status

  aasm_initial_state :proposed

  aasm_state :proposed
  aasm_state :accepted
  aasm_state :rejected
  aasm_state :confirmed
  aasm_state :declined
  aasm_state :junk
  aasm_state :cancelled

  aasm_event :accept do
    transitions :from => :proposed, :to => :accepted
    transitions :from => :rejected, :to => :accepted
  end

  aasm_event :reject do
    transitions :from => :proposed, :to => :rejected
    transitions :from => :accepted, :to => :rejected
  end

  aasm_event :confirm do
    transitions :from => :accepted, :to => :confirmed
  end

  aasm_event :decline do
    transitions :from => :accepted, :to => :declined
  end

  aasm_event :accept_and_confirm do
    transitions :from => :proposed, :to => :confirmed
  end

  aasm_event :mark_as_junk do
    transitions :from => :proposed, :to => :junk
  end

  aasm_event :reset_status do
    transitions :from => %w(accepted rejected confirmed declined junk cancelled), :to => :proposed
  end

  aasm_event :cancel  do
    transitions :from => :confirmed, :to => :cancelled
  end

  # Associations
  belongs_to :event
  belongs_to :track
  belongs_to :session_type
  belongs_to :room
  has_many :comments
  has_many :user_favorites
  has_many :users_who_favor, :through => :user_favorites, :source => :user

  has_and_belongs_to_many :users do
    def fullnames
      self.map(&:fullname).join(', ')
    end

    def emails
      self.map(&:email).join(', ')
    end
  end

  # Named scopes
  named_scope :unconfirmed, :conditions => ["status != ?", "confirmed"]
  named_scope :populated, :order => :submitted_at, :include => [{:event => [:rooms, :tracks]}, :session_type, :track, :room, :users]
  named_scope :scheduled, :conditions => "start_time IS NOT NULL"
  named_scope :located, :conditions => "room_id IS NOT NULL"
  named_scope :for_event, lambda { |event| { :conditions => { :event_id => event } } }

  # Validations
  validates_presence_of :title, :description, :event_id
  validates_acceptance_of :agreement,                     :accept => true, :message => "must be accepted"
  validates_presence_of :excerpt,                         :if => :proposal_excerpts?
  validates_presence_of :track,                           :if => :event_tracks?
  validates_presence_of :session_type,                    :if => :event_session_types?
  validates_presence_of :presenter, :email, :biography,   :unless => :user_profiles?
  validate :validate_complete_user_profile,               :if => :user_profiles?
  validate :url_validator

  # Protected attributes
  attr_protected :user_id, :event_id, :status, :transition

  # Public attributes for export
  include PublicAttributesMixin
  set_public_attributes :id, :user_id, :presenter, :affiliation, :website, :biography, :title, :description, :created_at, :updated_at, :event_id, :submitted_at

  # Triggers
  before_save :populate_submitted_at

  # CSV Export

  base_comma_attributes = lambda {
    id
    submitted_at
    track :title => "Track" if SETTINGS.have_event_tracks
    title
    excerpt if SETTINGS.have_proposal_excerpts
    description

    if SETTINGS.have_event_session_types
      session_type :title => "Session Type"
      session_type :duration => "Duration"
    end

    # TODO how to better support multiple speakers!?
    if SETTINGS.have_multiple_presenters
      users :fullnames => "Speakers"
    else
      presenter
      affiliation
      website
      biography
    end
  }

  schedule_comma_attributes = lambda {
    room :name => "Room Name"
    start_time :xmlschema => "Start Time"
  }

  comma do
    instance_eval &base_comma_attributes
  end

  comma :schedule do
    instance_eval &base_comma_attributes
    instance_eval &schedule_comma_attributes
  end

  comma :admin do
    instance_eval &base_comma_attributes
    instance_eval &schedule_comma_attributes

    if SETTINGS.have_multiple_presenters
      users :emails
    else
      email
    end
    note_to_organizers
    comments_text
  end

  # Return the first User owner. Burst into flames if no user or multiple users listed.
  def user
    raise ArgumentError, "Can't lookup user when in multiple presenters mode" if multiple_presenters?
    return self.users.first
  end

  # generates a unique slug for the proposal
  def slug
    return "#{SETTINGS.organization_slug}#{event.ergo.id}-%04d" % id
  end

  # returns a proposal's duration based on its session type
  def duration
    self.session_type.ergo.duration
  end

  # Return the time this session ends.
  def end_time
    self.start_time + (self.duration || 0).minutes
  end

  # Return array of arrays, the first representing the current state, the rest
  # representing optional states. Of each pair, the first element is the title,
  # the second is the status.
  def titles_and_statuses
    result = [["(currently '#{self.aasm_current_state.to_s.titleize}')", nil]]
    result += self.aasm_events_for_current_state.map{|s|[s.to_s.titleize, s.to_s]}
    return result
  end

  # allows an interface to state machine through update_attributes transition key
  attr_accessor :transition
  def transition=(event)
    send("#{event}!") if !event.blank? && aasm_events_for_current_state.include?(event.to_sym)
  end

  # Is this +user+ allowed to alter this proposal?
  def can_alter?(user)
    return false unless user

    user = User.get(user)
    if user.admin?
      return true
    else
      # Check this proposal's owners and confirm the proposal's status is 'proposed'
      # FIXME decide when we prevent users from modifying their records
      #IK# return self.users.include?(user) && self.proposed?
      return self.users.include?(user)
    end
  end

  # Return the comments as text.
  def comments_text
    return self.comments.inject("") do |string, comment|
      string +
        (string.empty? ? "" : "\n") +
        comment.email +
        ": " +
        comment.message
    end
  end

  # Save original created_at time because it doesn't survive database reloads.
  def populate_submitted_at
    self.submitted_at ||= self.created_at || Time.now
    return true
  end

  # Validation for making sure user has a complete profile
  def validate_complete_user_profile
    unless self.user_has_complete_profile?
      self.errors.add(:user, "must have a complete profile")
    end
  end

  # Does this profile have a user with a complete profile?
  def user_has_complete_profile?
    self.users.each do |user|
      if user.blank? || !user.complete_profile?
        return false
      end
    end
    return true
  end

  # Add user by record or id if needed. Return user object if added.
  def add_user(user)
    user = User.get(user)

    if self.users.include?(user)
      return nil
    else
      Observist.expire
      self.users << user
      return user
    end
  end

  # Remove user by record or id if needed. Return user object if removed.
  def remove_user(user)
    user = User.get(user)

    if self.users.include?(user)
      Observist.expire
      self.users.delete(user)
      return user
    else
      return nil
    end
  end

  # Return the object with profile information (e.g., biography). The
  # object can be either a Proposal or a User, or false when there isn't
  # just one presenter per proposal.
  def profile
    if multiple_presenters?
      return false
    elsif user_profiles?
      return user
    else
      return self
    end
  end

  # Validate that the record has a blank or valid URL, else add a
  # validation error.
  def url_validator
    validate_url_attribute(:website)
  end

  # Return string with a "mailto:" link for contacting the proposal's speakers.
  def mailto_link
    link = "mailto:"
    if multiple_presenters?
      link << self.users.map(&:email).join(",")
    else
      link << self.profile.email
    end
    return link
  end
  
  # Returns a string labeling a proposal object as either a proposal or a session depending on its state.
  def kind_label
    return self.confirmed? ? 'session' : 'proposal'
  end
  
  # Returns URL of session notes for this proposal, if available.
  # 
  # Reads optional SETTINGS.session_notes_wiki_url_format. This 'printf' format
  # contains positional variables that filled by Proposal#session_notes_url:
  #   * %1 => site's public URL
  #   * %2 => parent OR event slug
  #   * %3 => event slug
  #
  # E.g., '%1$s%2$s/wiki/' may translate to 'http://my_site.com/my_parent_slug/wiki'
  def session_notes_url
    escape = lambda{|string| self.class._session_notes_url_escape(string)}

    if SETTINGS.session_notes_wiki_url_format && ! self.title.blank?
      return (
        sprintf(
          SETTINGS.session_notes_wiki_url_format,
          SETTINGS.public_url,
          escape[self.event.parent_or_self.slug],
          escape[self.event.slug]
        ) \
        + escape[self.title]
      )
    end
  end

  # Return escaped string for use in a URL in the session notes wiki.
  def self._session_notes_url_escape(string)
    return CGI.escape(string.gsub(/\s+/, '_').squeeze('_'))
  end

  # Return array of +proposals+ sorted by +field+ (e.g., "title") in +ascending+ order.
  def self.sort(proposals, field="title", is_ascending=true)
    proposals = \
      case field.to_sym
      when :track
        without_tracks = proposals.reject(&:track)
        with_tracks = proposals.select(&:track).sort_by{|proposal| [proposal.track, proposal.title]}
        with_tracks + without_tracks
      when :start_time
        proposals.select{|proposal| !proposal.start_time.nil? }.sort_by{|proposal| proposal.start_time.to_i }.concat(proposals.select{|proposal| proposal.start_time.nil?})
      when :submitted_at
        proposals.sort_by(&:submitted_at)
      else
        proposals.sort_by{|proposal| proposal.send(field).to_s.downcase rescue nil}
      end
    proposals = proposals.reverse unless is_ascending
    return proposals
  end

  # Return a string of iCalendar data for the given +items+.
  #
  # Options:
  # * :title => String to use as the calendar title. Optional.
  # * :url_helper => Lambda that's called with an item that should return
  #   the URL for the item. Optional, defaults to not returning a URL.
  def self.to_icalendar(items, opts={})
    title = opts[:title] || "Schedule"
    url_helper = opts[:url_helper]

    calendar = Vpim::Icalendar.create2(Vpim::PRODID)
    calendar.title = title
    calendar.time_zone = Time.zone.tzinfo.name
    items.each do |item|
      calendar.add_event do |e|
        e.dtstart     item.start_time
        e.dtend       item.start_time + item.duration.minutes
        e.summary     item.title
        e.created     item.created_at if item.created_at
        e.lastmod     item.updated_at if item.updated_at
        e.description item.excerpt
        if item.room
          e.set_text  'LOCATION', item.room.name 
        end
        if url_helper
          url = url_helper.call(item)
          e.url       url
          e.uid       url
        end
      end
    end
    return calendar.encode.sub(/CALSCALE:Gregorian/, "CALSCALE:Gregorian\nMETHOD:PUBLISH")
  end

  def self.populated_proposals_for(container)
    args = [:event, :room, :session_type, :track, :users]
    case container
    when User
      # Can't eager fetch users for users for some reason, yet all other combinations work fine.
      args.delete(:users)
    end
    return container.proposals.all(:include => args)
  end

end
