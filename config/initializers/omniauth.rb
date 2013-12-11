OmniAuth.config.path_prefix = OpenConferenceWare.mounted_path("/auth")

Rails.application.config.middleware.use OpenConferenceWare::OmniAuthBuilder do
  provider :developer if %w[development preview].include?(Rails.env)

  require 'openid/store/filesystem'
  provider :openid, store: OpenID::Store::Filesystem.new(Rails.root.join('tmp'))
  provider :persona
end
