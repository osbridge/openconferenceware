# Edit this file to configure OpenConferenceWare's settings

OpenConferenceWare.configure do |config|
  # The path where the OpenConferenceWare engine is mounted in your Rails app
  # This default should work in most situations, but may need to be overridden
  # in some cases with a string like "/open_conference_ware"
  config.mount_point = '<%= mount_point %>'

  # Mailer host
  # The hostname to use when generating links in emails.
  # This shoud be the domain where OCW is hosted.
  config.mailer_host = 'ocw.local'

  # Event name, or organization running events:
  config.organization = 'Open Source Bridge'

  # Abbreviated name for use in URLs and proposal slugs.
  config.organization_slug = 'osb'

  # Top-level tagline or description.
  config.tagline = 'The conference for open source citizens'

  # What is the slug for the current event? E.g., if this is '2014' and the user
  # visits the '/proposals' URI, then the system will try to lookup an Event with
  # the '2012' slug and redirect to '/events/2012/proposals' if it's available.
  #
  # TODO: Setting the current event here is a short-term hack and will be replaced shortly with a Site record that tracks the current event in the database and provides a way to set it through an admin web UI.
  # config.current_event_slug = '2012'

  ##[ Secrets ]##
  # Some are sensitive and should not be checked in to version control.
  # These are loaded from config/secrets.yml, which should be privately copied to your
  # server and linked by your deployment process.

  secrets_file = Rails.root.join('config', 'secrets.yml')
  if File.exists?(secrets_file)
    secrets = YAML.load_file(secrets_file)
    config.administrator_email = secrets["administrator_email"]
    config.comments_secret = secrets["comments_secret"]
    config.secret_key_base = secrets["secret_key_base"]
  else
    raise "Oops, config/secrets.yml could not be found."
  end

  ##[ OCW Features ]##
  # Many features of OpenConferenceWare can be toggled via these settings

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

  # Can users note their favorite sessions?
  config.have_user_favorites = true

  # What audience experience levels can a proposal be classified as?
  # The list will be displayed on the form in the order defined below.
  # The "slug" is the unique key defining the particular audience level, while
  # the "label" is the human-readable value displayed.
  #
  # Set this to a blank array to disable audience levels
  config.proposal_audience_levels = [
    {slug: 'a', label: 'Beginner'},
    {slug: 'b', label: 'Intermediate'},
    {slug: 'c', label: 'Advanced'}
  ]

  # What message is displayed as a hint to explain the audience level?
  config.proposal_audience_level_hint = "(Tell us the intended audience experience level for this talk)"

  ##[ Session Notes ]##
  #
  # OCW can generate links to an external system, such as a wiki or an Etherpad
  # instance, that provides a place for attendees to take notes.

  # URL where OCW is installed
  config.app_root_url = 'http://opensourcebridge.org/'

  # URL of wiki with session notes (optional). This 'printf' format contains
  # positional variables that filled by Proposal#session_notes_url:
  #   * %1 => site's public URL
  #   * %2 => parent OR event slug
  #   * %3 => event slug
  # E.g., '%1$s%2$s/wiki/' may translate to 'http://my_site.com/my_parent_slug/wiki'
  config.session_notes_url_format = '%1$swiki/%2$s/'

  ##[ Optional Settings ]##

  # Policy agreement to show on the proposal form
  # If an agreement is set, presenters will be required to agree in order to submit a proposal.
  #
  # config.agreement =  'I have reviewed and agree to the recording policy and code of conduct.'

  # Breadcrumbs that are always visible, each breadcrumb is a name and URI:
  # NOTE: The current default theme never displays any breadcrumbs, but infrastructure exists to support them.
  #
  # config.breadcrumbs = [['Home', 'http://openconferenceware.org']]
end
