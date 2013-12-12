OmniAuth.config.path_prefix = OpenConferenceWare.mounted_path("/auth")

Rails.application.config.middleware.use OpenConferenceWare::OmniAuthBuilder do
  provider :developer if %w[development preview].include?(Rails.env)

  # OpenID
  # add 'omniauth-openid' to Gemfile and uncomment to enable OpenID
  #
  require 'omniauth-openid'
  require 'openid/store/filesystem'
  provider :openid, store: OpenID::Store::Filesystem.new(Rails.root.join('tmp'))

  # Persona
  # add 'omniauth-persona' to Gemfile and uncomment to enable Persona
  #
  #provider :persona
end
