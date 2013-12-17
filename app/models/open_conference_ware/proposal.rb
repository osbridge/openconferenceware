module OpenConferenceWare

  # == Schema Information
  #
  # Table name: proposals
  #
  #  id                  :integer          not null, primary key
  #  user_id             :integer
  #  presenter           :string(255)
  #  affiliation         :string(255)
  #  email               :string(255)
  #  website             :string(255)
  #  biography           :text
  #  title               :string(255)
  #  description         :text
  #  agreement           :boolean          default(TRUE)
  #  created_at          :datetime
  #  updated_at          :datetime
  #  event_id            :integer
  #  submitted_at        :datetime
  #  note_to_organizers  :text
  #  excerpt             :text
  #  track_id            :integer
  #  session_type_id     :integer
  #  status              :string(255)      default("proposed"), not null
  #  room_id             :integer
  #  start_time          :datetime
  #  audio_url           :string(255)
  #  speaking_experience :text
  #  audience_level      :string(255)
  #  notified_at         :datetime
  #

  class Proposal < OpenConferenceWare::Base
    # Provide ::validate_url_attribute
    include NormalizeUrlMixin

    # Provide ::event_tracks? and other methods for accessing SETTING
    include SettingsCheckersMixin

    # Provide ::overlaps?
    include ScheduleOverlapsMixin

    # Public attributes for export
    include PublicAttributesMixin
    set_public_attributes :id, :user_id,
      :presenter, :affiliation, :website,
      :biography, :title, :description,
      :created_at, :updated_at, :submitted_at,
      :start_time, :end_time,
      :event_id, :event_title,
      :room_id, :room_title,
      :session_type_id, :session_type_title,
      :track_id, :track_title,
      :user_ids, :user_titles

    # Provide #tags
    acts_as_taggable_on :tags

    # Acts As State Machine
    include AASM

    aasm(column: :status) do

      state :proposed, initial: true
      state :accepted
      state :waitlisted
      state :rejected
      state :confirmed
      state :declined
      state :junk
      state :cancelled

      event :accept do
        transitions from: :proposed, to: :accepted
        transitions from: :rejected, to: :accepted
        transitions from: :waitlisted, to: :accepted
      end

      event :reject do
        transitions from: :proposed, to: :rejected
        transitions from: :accepted, to: :rejected
        transitions from: :waitlisted, to: :rejected
      end

      event :waitlist do
        transitions from: :proposed, to: :waitlisted
        transitions from: :accepted, to: :waitlisted
        transitions from: :rejected, to: :waitlisted
      end

      event :confirm do
        transitions from: :accepted, to: :confirmed
      end

      event :decline do
        transitions from: :accepted, to: :declined
      end

      event :accept_and_confirm do
        transitions from: :proposed, to: :confirmed
        transitions from: :waitlisted, to: :confirmed
      end

      event :accept_and_decline do
        transitions from: :proposed, to: :declined
        transitions from: :waitlisted, to: :declined
      end

      event :mark_as_junk do
        transitions from: :proposed, to: :junk
      end

      event :reset_status do
        transitions from: %w(accepted rejected waitlisted confirmed declined junk cancelled), to: :proposed
      end

      event :cancel  do
        transitions from: :confirmed, to: :cancelled
      end
    end

    # Associations
    belongs_to :event
    belongs_to :track
    belongs_to :session_type
    belongs_to :room
    has_many :comments, dependent: :destroy
    has_many :user_favorites, dependent: :destroy
    has_many :users_who_favor, through: :user_favorites, source: :user
    has_many :selector_votes

    has_and_belongs_to_many :users do
      def fullnames
        self.map(&:fullname).join(', ')
      end

      def emails
        self.map(&:email).join(', ')
      end
    end

    # Named scopes
    scope :unconfirmed, lambda { where("status != ?", "confirmed") }
    scope :populated,   lambda { order(:submitted_at).includes( {event: [:rooms, :tracks]}, :session_type, :track, :room, :users ) }
    scope :scheduled,   lambda { where("start_time IS NOT NULL") }
    scope :located,     lambda { where("room_id IS NOT NULL") }
    scope :for_event,   lambda { |event| where(event_id: event) }

    # Validations
    validates_presence_of :title, :description, :event_id
    validates_acceptance_of :agreement,                     accept: true, message: "must be accepted", if: -> { OpenConferenceWare.agreement.present? }
    validates_presence_of :excerpt,                         if: :proposal_excerpts?
    validates_presence_of :track,                           if: :event_tracks?
    validates_presence_of :session_type,                    if: :event_session_types?
    validates_presence_of :presenter, :email, :biography,   unless: :user_profiles?
    validates_presence_of :speaking_experience,             if: :proposal_speaking_experience?
    validates_presence_of :audience_level,                  if: Proc.new { Proposal.audience_levels.present? }
    validates_inclusion_of :audience_level,                 if: Proc.new { Proposal.audience_levels.present? }, allow_blank: true,
                                                            in: OpenConferenceWare.proposal_audience_levels ?
                                                                  OpenConferenceWare.proposal_audience_levels.flatten.map { |level| level.with_indifferent_access['slug'] } :
                                                                  []
    validate :validate_complete_user_profile,               if: :user_profiles?
    validate :url_validator

    # Triggers
    before_save :populate_submitted_at

    # CSV Export

    base_comma_attributes = Proc.new {
      id
      submitted_at
      track title: "Track" if OpenConferenceWare.have_event_tracks
      title
      excerpt if OpenConferenceWare.have_proposal_excerpts
      description
      audience_level_label "Audience Level"

      if OpenConferenceWare.have_event_session_types
        session_type title: "Session Type"
        session_type duration: "Duration"
      end

      # TODO how to better support multiple speakers!?
      if OpenConferenceWare.have_multiple_presenters
        users fullnames: "Speakers"
      else
        presenter
        affiliation
        website
        biography
      end
    }

    schedule_comma_attributes = Proc.new {
      room name: "Room Name"
      start_time("Start Time") {|t| t.try(:xmlschema) }
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
      speaking_experience
      status
      instance_eval &schedule_comma_attributes

      if OpenConferenceWare.have_multiple_presenters
        users :emails
      else
        email
      end
      note_to_organizers
      comments_text
      user_favorites size: 'Favorites count'
    end

    comma :selector_votes do
      instance_eval &base_comma_attributes

      user_favorites size: 'Favorites count'
      selector_vote_points 'Selector points'
      selector_votes_for_comma 'Selector votes'
      comments_for_comma 'Comments'
    end

    # Return the first User owner. Burst into flames if no user or multiple users listed.
    def user
      raise ArgumentError, "Can't lookup user when in multiple presenters mode" if multiple_presenters?
      return self.users.first
    end

    # generates a unique slug for the proposal
    def slug
      return "#{OpenConferenceWare.organization_slug}#{event.try(:slug)}-%04d" % id
    end

    # returns a proposal's duration based on its session type
    def duration
      self.session_type.try(:duration)
    end

    # Return the time this session ends.
    def end_time
      if self.start_time
        self.start_time + (self.duration || 0).minutes
      else
        nil
      end
    end

    # Return array of arrays, the first representing the current state, the rest
    # representing optional states. Of each pair, the first element is the title,
    # the second is the status.
    def titles_and_statuses
      result = [["(currently '#{self.aasm.current_state.to_s.titleize}')", nil]]
      result += self.aasm.events(aasm.current_state).map{|s|[s.to_s.titleize, s.to_s]}.sort_by{|title, state| title}
      return result
    end

    # allows an interface to state machine through update_attributes transition key
    attr_accessor :transition
    def transition=(event)
      send("#{event}!") if !event.blank? && aasm.events(aasm.current_state).include?(event.to_sym)
    end

    # Is this +user+ allowed to alter this proposal?
    def can_alter?(user)
      return false unless user

      user = User.get(user)
      if user.admin?
        return true
      else
        return self.users(true).include?(user)
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
        CacheWatcher.expire
        self.users << user
        return user
      end
    end

    # Remove user by record or id if needed. Return user object if removed.
    def remove_user(user)
      user = User.get(user)

      if self.users.include?(user)
        CacheWatcher.expire
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
      return link << mailto_emails
    end

    # Return string with the proposal's speakers' emails.
    def mailto_emails
      if multiple_presenters?
        return self.users.map(&:email).join(", ")
      else
        return self.profile.email
      end
    end

    # Returns a string labeling a proposal object as either a proposal or a session depending on its state.
    def kind_label
      return self.confirmed? ? 'session' : 'proposal'
    end

    # Returns URL of session notes for this proposal, if available.
    #
    # Reads optional OpenConferenceWare.session_notes_url_format. This 'printf' format
    # contains positional variables that filled by Proposal#session_notes_url:
    #   * %1 => site's public URL
    #   * %2 => parent OR event slug
    #   * %3 => event slug
    #
    # E.g., '%1$s%2$s/wiki/' may translate to 'http://my_site.com/my_parent_slug/wiki'
    def session_notes_url
      escape = lambda{|string| self.class._session_notes_url_escape(string)}

      if OpenConferenceWare.public_url && OpenConferenceWare.session_notes_url_format && ! self.title.blank?
        return (
          sprintf(
            OpenConferenceWare.session_notes_url_format,
            OpenConferenceWare.public_url,
            escape[self.event.parent_or_self.slug],
            escape[self.event.slug]
          ) \
          + escape[self.title]
        )
      end
    end

    # Return escaped string for use in a URL in the session notes wiki.
    def self._session_notes_url_escape(string)
      return CGI.escape(string.gsub(/\s/, '_').gsub(/[\\\/\(\)\[\]]+/, '-').gsub(/[<>]/,'').squeeze('_').squeeze('-'))
    end

    # Return the proposal's title downcased or nil.
    def title_downcased
      return self.title.try(:downcase)
    end

    # Return array of +proposals+ sorted by +field+ (e.g., "title") in +ascending+ order.
    def self.sort(proposals, field="title", is_ascending=true)
      proposals = \
        case field.to_sym
        when :track
          partitioned = proposals.partition{|proposal| proposal.track.nil?}
          without_tracks = partitioned.first.sort_by(&:title)
          with_tracks = partitioned.last.select(&:track).sort_by{|proposal| [proposal.track, proposal.title]}
          with_tracks + without_tracks
        when :start_time
          proposals.select{|proposal| !proposal.start_time.nil? }.sort_by{|proposal| proposal.start_time.to_i }.concat(proposals.select{|proposal| proposal.start_time.nil?})
        when :submitted_at
          proposals.sort_by(&:submitted_at)
        when :title
          proposals.sort_by{|proposal| proposal.title_downcased}
        when :status
          proposals.sort_by{|proposal| [proposal.status, proposal.title_downcased]}
        else
          proposals.sort_by(&:submitted_at)
        end
      proposals = proposals.reverse unless is_ascending
      return proposals
    end

    # Return a string of iCalendar data for the given +items+.
    #
    # Options:
    # * title: String to use as the calendar title. Optional.
    # * url_helper: Lambda that's called with an item that should return
    #   the URL for the item. Optional, defaults to not returning a URL.
    def self.to_icalendar(items, opts={})
      title = opts[:title] || "Schedule"
      url_helper = opts[:url_helper]

      calendar = Vpim::Icalendar.create2(Vpim::PRODID)
      calendar.title = title
      calendar.time_zone = Time.zone.tzinfo.name
      items.each do |item|
        next if item.start_time.nil?
        calendar.add_event do |e|
          e.dtstart     item.start_time
          e.dtend       item.start_time + item.duration.minutes if item.duration
          e.summary     item.title
          e.created     item.created_at if item.created_at
          e.lastmod     item.updated_at if item.updated_at
          e.description((item.respond_to?(:users) ? "#{item.users.map(&:fullname).join(', ')}: " : '') + item.excerpt)
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
      return container.proposals.includes(args)
    end

    # Is this proposal related to the +event+, as in to the event, its parent or children?
    def related_to_event?(some_event)
      for an_event in [some_event, some_event.parent, some_event.parent_or_self.children].compact.flatten
        return true if self.event_id == an_event.id
      end
      return false
    end

    # Return next proposal in this event after this one, or nil if none.
    def next_proposal
      return self.event.proposals.where("id > ?", self.id).order("created_at ASC").first
    end

    # Return previous proposal in this event after this one, or nil if none.
    def previous_proposal
      return self.event.proposals.where("id < ?", self.id).order("created_at DESC").first
    end

    # Return the integer sum of the selector votes rating for this proposal. Skips
    # the "-1" votes because these mean "I don't know how to rate this proposal".
    def selector_vote_points
      return self.selector_votes.map(&:rating).reject{|o| o == -1}.sum
    end

    # Return the integer number of votes submitted that aren't abstensions.
    def selector_votes_count
      return self.selector_votes.map(&:rating).reject{|o| o == -1}.size
    end

    #---[ Accessors for getting the titles of related objects ]-------------

    def track_title
      return self.track.try(:title)
    end

    def room_title
      return self.room.try(:name)
    end

    def session_type_title
      return self.session_type.try(:title)
    end

    def event_title
      return self.event.try(:slug)
    end
    alias_method :event_slug, :event_title

    def user_titles
      return self.users.map(&:label).map(&:to_s)
    end
    alias_method :user_labels, :user_titles

    #---[ Audience level ]--------------------------------------------------

    # Return the audience levels. May be nil if not defined.
    #
    # Structure: array of hashes with a "label" and "slug".
    #
    # Example:
    #   [
    #     {"label"=>"Beginner", "slug"=>"a"},
    #     {"label"=>"Intermediate", "slug"=>"b"},
    #     {"label"=>"Advanced", "slug"=>"c"}
    #   ]
    def self.audience_levels
      OpenConferenceWare.proposal_audience_levels.present? &&
      OpenConferenceWare.proposal_audience_levels.map(&:with_indifferent_access)
    end

    # Return the text hint describing the audience level UI control.
    def self.audience_level_hint
      OpenConferenceWare.proposal_audience_level_hint
    end

    # Return the string label for the audience level, or nil if not set.
    def audience_level_label
      if ! self.audience_level.blank? && self.class.audience_levels
        return self.class.audience_levels.find { |level| level['slug'] == self.audience_level }['label']
      end
    end

    #---[ Notify speakers ]---------------------------------------------

    # returns [sent-emails, already-notified-emails]
    def notify_accepted_speakers
      if accepted?
        if !notified_at
          SpeakerMailer.speaker_accepted_email(self).deliver
          self.notified_at = Time.now
          self.save
          return [self.mailto_emails, nil]
        else
          return [nil, self.mailto_emails]
        end
      end
      return [nil, nil]
    end

    # returns [sent-emails, already-notified-emails]
    def notify_rejected_speakers
      if rejected?
        if !notified_at
          SpeakerMailer.speaker_rejected_email(self).deliver
          self.notified_at = Time.now
          self.save
          return [ self.mailto_emails, nil ]
        else
          return [ nil, self.mailto_emails ]
        end
      end
      return [ nil, nil ]
    end

    #---[ Accessors for comma ]---------------------------------------------

    def selector_votes_for_comma
      return self.selector_votes.map do |selector_vote|
        "#{selector_vote.rating == -1 ? 'Abstain' : selector_vote.rating}: #{selector_vote.comment}"
      end.join("\n")
    end

    def comments_for_comma
      return self.comments.map do |comment|
        "#{comment.email}: #{comment.message}"
      end.join("\n")
    end
  end
end
