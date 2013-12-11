module OpenConferenceWare
  module TracksHelper
    include FauxRoutesMixin

    def track_css_class(track)
      "track-#{track.id}"
    end
  end
end
