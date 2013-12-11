module OpenConferenceWare
  module AuthenticationsHelper
    def auth_path(provider)
      "#{OmniAuth.config.path_prefix}/#{provider}"
    end

    def auth_callback_path(provider)
    "#{OmniAuth.config.path_prefix}/#{provider}/callback"
    end
  end
end
