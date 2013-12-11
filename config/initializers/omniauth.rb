Rails.application.config.middleware.use OmniAuth::Builder do
  require 'openid/store/filesystem' 

  if %w[development preview].include?(Rails.env) && ActiveRecord::Base.connection.table_exists?('open_conference_ware_authentications')
    provider :developer

    admin_auth = Authentication.find_or_initialize_by(provider: :developer, uid: 'admin@ocw.local')
    admin_auth.name = "Development Admin"
    admin_auth.email = "admin@ocw.local"

    unless admin_auth.user
      admin_user = User.create_from_authentication(admin_auth)
      admin_user.assign_attributes({admin: true, biography: "I am mighty."}, as: :admin)
      admin_user.save!
    end

    mortal_auth = Authentication.find_or_initialize_by(provider: :developer, uid: 'mortal@ocw.local')
    mortal_auth.name = "Development User"
    mortal_auth.email = "mortal@ocw.local"

    unless mortal_auth.user
      mortal_user = User.create_from_authentication(mortal_auth)
      mortal_user.biography = "I'm ordinary."
      mortal_user.save!
    end
  end

  provider :openid, store: OpenID::Store::Filesystem.new(Rails.root.join('tmp'))
  provider :persona
end
