module OpenConferenceWare

  # = SettingsCheckersMixin
  #
  # The SettingsCheckersMixin provides methods for checking the status of the
  # settings, setup via the SettingsReader. These let you write code like
  # +#user_profiles?+ rather than +SETTINGS.has_user_profiles+.
  module SettingsCheckersMixin

    def self.included(mixee)
      mixee.extend(Methods)

      # Add view helper methods to controllers
      if mixee.ancestors.include?(ActionController::Base)
        mixee.class_eval do
          Methods.instance_methods.each do |name|
            helper_method(name)
          end
        end
      end
    end

    module Methods
      # Create methods like +#event_tracks?+ as wrappers for +OpenConferenceWare.have_event_tracks+.
      %w[
        anonymous_proposals
        event_proposal_comments_after_deadline
        event_tracks
        event_session_types
        events_picker
        event_rooms
        multiple_presenters
        proposal_excerpts
        proposal_speaking_experience
        proposal_start_times
        proposal_statuses
        user_pictures
        user_profiles
        user_favorites
      ].each do |name|
        define_method("#{name}?") do
          return OpenConferenceWare.send("have_#{name}")
        end
      end
    end

    include Methods
    extend Methods

  end
end
