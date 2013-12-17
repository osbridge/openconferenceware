require 'open_conference_ware/dependencies'
require "open_conference_ware/engine"

module OpenConferenceWare
  def self.configure(&block)
    yield(self)
  end

  # Engine Configuration

  # Path where the OCW engine is mounted
  mattr_accessor :mount_point
  self.mount_point ||= "/"

  def self.mounted_path(path)
    "#{self.mount_point}/#{path}".gsub(/\/\/+/,"/")
  end

  # Secrets
  mattr_accessor :email

  # Email address of administrator that will get exception notifications
  # and requests for assistance from users:
  mattr_accessor :administrator_email

  # Secret key for getting an ATOM feed of private comments:
  mattr_accessor :comments_secret

  # The secret_key_base, which we'll pass on to Rails
  mattr_accessor :secret_key_base

  # Email

  mattr_accessor :default_from_address
  self.default_from_address ||= 'ocw@ocw.local'

  mattr_accessor :default_bcc_address

  # Settings

  # Public URL of website:
  mattr_accessor :public_url
  self.public_url ||= 'http://ocw.local/'

  # URL where OCW is installed
  mattr_accessor :app_root_url
  self.app_root_url ||= 'http://ocw.local/'

  # Mailer host
  mattr_accessor :mailer_host
  self.mailer_host ||= 'ocw.local'

  # URL of wiki with session notes (optional). This 'printf' format contains
  # positional variables that filled by Proposal#session_notes_url:
  #   * %1 => site's public URL
  #   * %2 => parent OR event slug
  #   * %3 => event slug
  # E.g., '%1$s%2$s/wiki/' may translate to 'http://my_site.com/my_parent_slug/wiki'
  mattr_accessor :session_notes_url_format

  # Organization running event:
  mattr_accessor :organization
  self.organization ||= 'Open Conference Ware'

  # Abbreviated name for use in URLs and proposal slugs.
  mattr_accessor :organization_slug
  self.organization_slug ||= 'osb'

  # Twitter account for the event (optional)
  mattr_accessor :twitter
  # self.twitter ||= 'openconferenceware'

  # Top-level tagline or description.
  mattr_accessor :tagline
  self.tagline ||= 'A truly great event.'

  # Aggreement to show on proposal pages. (optional)
  mattr_accessor :agreement
  #self.agreement ||= 'I have reviewed and agree to the recording policy and code of conduct.'

  # Breadcrumbs that are always visible, each breadcrumb is a name and URI:
  mattr_accessor :breadcrumbs
  self.breadcrumbs ||= []

  # What is the slug for the current event? E.g., if this is '2009' and the user visits the '/proposals' URI, then the system will try to lookup an Event with the '2009' slug and redirect to '/events/2009 proposals' if it's available.
  mattr_accessor :current_event_slug
  self.current_event_slug ||= '2013'

  # Can people create proposals without logging in?
  mattr_accessor :have_anonymous_proposals
  self.have_anonymous_proposals ||= false

  # Do proposals have excerpts?
  mattr_accessor :have_proposal_excerpts
  self.have_proposal_excerpts ||= true

  # Do events have tracks?
  mattr_accessor :have_event_tracks
  self.have_event_tracks ||= true

  # Do events have session types?
  mattr_accessor :have_event_session_types
  self.have_event_session_types ||= true

  # Display events picker so user can pick between multiple events?
  mattr_accessor :have_events_picker
  self.have_events_picker ||= false

  # Are proposals associated with multiple presenters?
  mattr_accessor :have_multiple_presenters
  self.have_multiple_presenters ||= true

  # Can people upload pictures of themselves?
  mattr_accessor :have_user_pictures
  self.have_user_pictures ||= true

  # Is profile information, like biography, stored in the User record? Else stored in Proposal.
  mattr_accessor :have_user_profiles
  self.have_user_profiles ||= true

  # Do events have rooms?
  mattr_accessor :have_event_rooms
  self.have_event_rooms ||= true

  # Should a proposal ask for the submitter's speaking experience?
  mattr_accessor :have_proposal_speaking_experience
  self.have_proposal_speaking_experience ||= true

  # Can proposals have start times?
  mattr_accessor :have_proposal_start_times
  self.have_proposal_start_times ||= true

  # Can proposals have statuses?
  mattr_accessor :have_proposal_statuses
  self.have_proposal_statuses ||= true

  # Can users add comments until a toggle is flipped on the event?
  mattr_accessor :have_event_proposal_comments_after_deadline
  self.have_event_proposal_comments_after_deadline ||= true

  # Can users note their favorite sessions?
  mattr_accessor :have_user_favorites
  self.have_user_favorites ||= true


  # What audience experience levels can a proposal be classified as? The list will be displayed on the form in the order defined below. The "slug" is the unique key defining the particular audience level, while the "label" is the human-readable value displayed.
  mattr_accessor :proposal_audience_levels
  self.proposal_audience_levels ||= [
    {slug: 'a', label: 'Beginner'},
    {slug: 'b', label: 'Intermediate'},
    {slug: 'c', label: 'Advanced'}
  ]

  # What message is displayed as a hint to explain the audience level?
  mattr_accessor :proposal_audience_level_hint
  self.proposal_audience_level_hint ||= "(Tell us the intended audience experience level for this talk)"

  # Loaded authentication providers
  mattr_accessor :auth_providers
  self.auth_providers ||= []
end

