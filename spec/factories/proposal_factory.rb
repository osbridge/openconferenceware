# Return a proposal for the +event+, using it's session_types, tracks and
# rooms. Accepts an optional +opts+ which is passed to the :proposal factory.
#
# Example:
#   event = Factory :populated_event
#   proposal = proposal_for_event(event)
#   proposal2 = proposal_for_event(event, :user => (Factory :user))
def proposal_for_event(event, opts={})
  options = {
    :event => event,
    :session_type => event.session_types.first,
    :track => event.tracks.first,
    :room => event.rooms.first
  }.merge(opts)

  return Factory :proposal, options
end

def session_for_event(event, opts={})
  proposal = proposal_for_event(event, opts)
  proposal.status = "confirmed"
  proposal.users << Factory(:user) if opts[:users].nil?
  proposal.save!
  return proposal
end

# NOTE: A proposal's relationship to it's user profile information is
# configurable. If `SETTINGS.have_user_profiles` is false, then the proposal
# contains the user profile information (e.g., presenter's name). However,
# if false, the proposal has many users that each have their own profile as
# part of their user record.
Factory.define :proposal do |f|
  f.user_id nil
  f.presenter "Presenter name"
  f.affiliation "My affiliation"
  f.email { Factory.next(:email) }
  f.website { Factory.next(:website) }
  f.biography "My biography"
  f.sequence(:title) { |n| "Proposal #{n}" }
  f.description "My proposal description"
  f.agreement true
  f.note_to_organizers "My note to organizers"
  f.excerpt "My excerpt"
  f.status "proposed"
  f.start_time nil

  # :belongs_to associations:
  # * :event
  # * :track
  # * :session_type
  # * :room
  # * :users
end
