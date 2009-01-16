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
    # Do users have profiles with things like biography, or are things like biography stored in the proposal?
    def user_profiles?
      SETTINGS.has_user_profiles
    end
  end

  include Methods
  extend Methods

end
