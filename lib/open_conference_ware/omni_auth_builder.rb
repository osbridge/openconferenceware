module OpenConferenceWare
  class OmniAuthBuilder < ::OmniAuth::Builder
    def provider(*args)
      OpenConferenceWare.auth_providers << args.first
      super
    end
  end
end
