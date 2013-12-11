module OpenConferenceWare
  module AuthenticationsHelper
    def auth_path(provider)
      "/auth/#{provider}"
    end

    def auth_callback_path(provider)
      "/auth/#{provider}/callback"
    end
  end
end
