module OpenConferenceWare
  module AuthenticationsHelper
    def auth_path(provider)
      "#{OmniAuth.config.path_prefix}/#{provider}"
    end

    def auth_callback_path(provider)
      "#{OmniAuth.config.path_prefix}/#{provider}/callback"
    end

    def grouped_auth_providers
      @grouped_auth_providers ||= OpenConferenceWare.auth_providers.group_by do |provider|
        lookup_context.find_all("open_conference_ware/authentications/_#{provider}").any? ? :with_partials : :without_partials
      end
    end

    def auth_providers_with_partials
      grouped_auth_providers[:with_partials]
    end

    def auth_providers_without_partials
      grouped_auth_providers[:without_partials]
    end
  end
end
