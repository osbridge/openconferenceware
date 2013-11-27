Rails.application.config.middleware.use OmniAuth::Builder do
  require 'openid/store/filesystem' 
  if %w[development preview].include?(Rails.env)
    provider :developer, :fields => [:name, :email, :admin], :uid_field => :name
  end
  provider :openid, :store => OpenID::Store::Filesystem.new(Rails.root.join('tmp'))
  provider :persona
end
