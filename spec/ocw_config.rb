OpenConferenceWare.configure do |config|
  # Public URL of website:
  config.public_url = 'http://opensourcebridge.org/'

  # URL where OCW is installed
  config.app_root_url = 'http://opensourcebridge.org/'

  # URL of wiki with session notes (optional). This 'printf' format contains
  # positional variables that filled by Proposal#session_notes_url:
  #   * %1 => site's public URL
  #   * %2 => parent OR event slug
  #   * %3 => event slug
  # E.g., '%1$s%2$s/wiki/' may translate to 'http://my_site.com/my_parent_slug/wiki'
  config.session_notes_url_format = '%1$swiki/%2$s/'

  # Organization running event:
  config.organization = 'Open Source Bridge'

  # Abbreviated name for use in URLs and proposal slugs.
  config.organization_slug = 'osb'

  # Top-level tagline or description.
  config.tagline = 'The conference for open source citizens / June 26-29, 2012 / Portland, OR'

  # Aggreement to show on proposal pages.
  config.agreement =  'I have reviewed and agree to the <a href="http://opensourcebridge.org/about/recording-policy/" target="_blank">recording policy</a> and <a href="http://opensourcebridge.org/about/code-of-conduct/" target="_blank">code of conduct</a>. I understand that Open Source Bridge is not the appropriate place for commercial promotion ("spam") of a product, service or solution and this not welcomed by the audience.'

  # Breadcrumbs that are always visible, each breadcrumb is a name and URI:
  config.breadcrumbs = []

  # What is the slug for the current event? E.g., if this is '2009' and the user visits the '/proposals' URI, then the system will try to lookup an Event with the '2009' slug and redirect to '/events/2009 proposals' if it's available.
  # TODO: Setting the current event here is a short-term hack and will be replaced shortly with a Site record that tracks the current event in the database and provides a way to set it through an admin web UI.
  config.current_event_slug = '2012'

  # Can people create proposals without logging in?
  config.have_anonymous_proposals = false

  # Do proposals have excerpts?
  config.have_proposal_excerpts = true

  # Do events have tracks?
  config.have_event_tracks = true

  # Do events have session types?
  config.have_event_session_types = true

  # Display events picker so user can pick between multiple events?
  config.have_events_picker = false

  # Are proposals associated with multiple presenters?
  config.have_multiple_presenters = true

  # Can people upload pictures of themselves?
  config.have_user_pictures = true

  # Is profile information, like biography, stored in the User record? Else stored in Proposal.
  config.have_user_profiles = true

  # Do events have rooms?
  config.have_event_rooms = true

  # Should a proposal ask for the submitter's speaking experience?
  config.have_proposal_speaking_experience = true

  # Can proposals have start times?
  config.have_proposal_start_times = true

  # Can proposals have statuses?
  config.have_proposal_statuses = true

  # Can users add comments until a toggle is flipped on the event?
  config.have_event_proposal_comments_after_deadline = true

  # What message is displayed as a hint to explain the audience level?
  config.proposal_audience_level_hint = "(Tell us the intended audience experience level for this talk)"
end
