# Return a populated record of the given +kind+ (e.g., Event or :event) that's
# connected to a complete graph of data. Override specific parts of the graph
# by setting hash options for :tracks, :session_types, :rooms, or :proposals.
#
# Example:
#   event = populated :event, :tracks => [Factory.build(:track)]
def populated(kind, opts={})
  tracks = opts[:tracks] || []
  session_types = opts[:session_types] || []
  rooms = opts[:rooms] || []
  proposals = opts[:proposals] || []

  event = Factory :event

  if opts[:tracks]
    event.tracks = tracks
  else
    tracks = [Factory.build(:track), Factory.build(:track)]
    event.tracks = tracks
  end

  if opts[:session_types]
    event.session_types = session_types
  else
    session_types = [Factory.build(:session_type), Factory.build(:session_type)]
    event.session_types = session_types
  end

  if opts[:rooms]
    event.rooms = rooms
  else
    rooms = [Factory.build(:room), Factory.build(:room)]
    event.rooms = rooms
  end

  if opts[:proposals]
    event.proposals = proposals
  else
    proposals = [
      Factory.build(:proposal, :room => event.rooms.first, :track => tracks.first, :session_type => event.session_types.first, :users => [Factory(:admin)]),
      Factory.build(:proposal, :room => event.rooms.first, :track => tracks.first, :session_type => event.session_types.first, :users => [Factory(:user)]),
      Factory.build(:proposal, :room => event.rooms.first, :track => tracks.first, :session_type => event.session_types.first, :users => [Factory(:user), Factory(:user)])
    ]
    event.proposals = proposals
  end

  case kind
  when Event, :event
    event
  when User, :user
    proposals.first.users.first
  when Proposal, :proposal
    proposals.first
  when Room, :room
    rooms.first
  when SessionType, :session_type
    session_types.first
  when Track, :track
    tracks.first
  else
    raise TypeError, "Unknown return type: #{kind}"
  end
end