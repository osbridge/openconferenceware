module TracksHelper
  include TracksFauxRoutesMixin
  
  def track_css_class(track)
    "track-#{track.title.underscore}"
  end
end
