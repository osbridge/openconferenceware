# Return a proposal for the +event+, using it's session_types, tracks and
# rooms. Accepts an optional +opts+ which is passed to the :proposal factory.
#
# Example:
#   event = create :populated_event
#   proposal = proposal_for_event(event)
#   proposal2 = proposal_for_event(event, :user => (create :user))
def proposal_for_event(event, opts={})
  options = {
    :event => event,
    :session_type => event.session_types.first,
    :track => event.tracks.first,
    :room => event.rooms.first
  }.merge(opts)

  return create :proposal, options
end

def session_for_event(event, opts={})
  proposal = proposal_for_event(event, opts)
  proposal.status = "confirmed"
  proposal.users << create(:user) if opts[:users].nil?
  proposal.save!
  return proposal
end

# NOTE: A proposal's relationship to it's user profile information is
# configurable. If `SETTINGS.have_user_profiles` is false, then the proposal
# contains the user profile information (e.g., presenter's name). However,
# if false, the proposal has many users that each have their own profile as
# part of their user record.
FactoryGirl.define do
  factory :proposal do
    user_id nil
    presenter "Presenter name"
    affiliation "My affiliation"
    email
    website
    biography "My biography"
    sequence(:title) { |n| "Proposal #{n}" }
    description "My proposal description"
    agreement true
    note_to_organizers "My note to organizers"
    excerpt "My excerpt"
    speaking_experience "My speaking experience is awesome"
    status "proposed"
    start_time nil
    audience_level "a"

    # :belongs_to associations:
    # * :event
    # * :track
    # * :session_type
    # * :room
    # * :users
  end
end
