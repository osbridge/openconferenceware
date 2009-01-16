# = SettingsCheckersMixin
#
# The SettingsCheckersMixin provides methods for checking the status of the
# SETTINGS, setup via the SettingsReader. These let you write code like
# +#user_profiles?+ rather than +SETTINGS.has_user_profiles+.
module SettingsCheckersMixin

  def self.included(mixee)
    mixee.extend(Methods)
  end

  module Methods
    def anonymous_proposals?
      return SETTINGS.have_anonymous_proposals
    end

    def tracks?
      return SETTINGS.have_tracks
    end

    def user_pictures?
      return SETTINGS.have_user_pictures
    end

    def user_profiles?
      return SETTINGS.have_user_profiles
    end
  end

  include Methods
  extend Methods

end
