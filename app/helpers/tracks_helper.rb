module TracksHelper
  include TracksFauxRoutesMixin
  
  def track_css_class(track)
    "track-#{track.title.gsub(/\W/, '_')}"
  end
end
