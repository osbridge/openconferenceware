# == Schema Information
# Schema version: 20090411093859
#
# Table name: proposals
#
#  id                 :integer         not null, primary key
#  user_id            :integer         
#  presenter          :string(255)     
#  affiliation        :string(255)     
#  email              :string(255)     
#  website            :string(255)     
#  biography          :string(255)     
#  title              :string(255)     
#  description        :string(255)     
#  agreement          :boolean         default(TRUE)
#  created_at         :datetime        
#  updated_at         :datetime        
#  event_id           :integer         
#  submitted_at       :datetime        
#  note_to_organizers :text            
#  excerpt            :text(400)       
#  track_id           :integer         
#  session_type_id    :integer         
#  status             :string(255)     default("proposed"), not null
#  room_id            :integer         
#  start_time         :datetime        
#

class Proposal < ActiveRecord::Base
  # Provide ::validate_url_attribute
  include NormalizeUrlMixin

  # Provide ::event_tracks? and other methods for accessing SETTING
  include SettingsCheckersMixin

  # Provide ::lookup
  include CacheLookupsMixin
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
    transitions :from => %w(accepted rejected confirmed declined junk), :to => :proposed
  end

  # Associations
  belongs_to :event
  belongs_to :track
  belongs_to :session_type
  belongs_to :room
  has_many :comments
  has_and_belongs_to_many :users

  # Named scopes
  named_scope :unconfirmed, :conditions => ["status != ?", "confirmed"]
  named_scope :populated, :order => :submitted_at, :include => [{:event => [:rooms, :tracks]}, :track, :room, :users]
  named_scope :scheduled, :conditions => "start_time IS NOT NULL"
  named_scope :located, :conditions => "room_id IS NOT NULL"

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

end
