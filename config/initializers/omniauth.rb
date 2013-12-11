OmniAuth.config.path_prefix = OpenConferenceWare.mounted_path("/auth")

Rails.application.config.middleware.use OmniAuth::Builder do
  require 'openid/store/filesystem' 

  if %w[development preview].include?(Rails.env) && ActiveRecord::Base.connection.table_exists?('open_conference_ware_authentications')
    provider :developer

    admin_auth = OpenConferenceWare::Authentication.find_or_initialize_by(provider: :developer, uid: 'admin@ocw.local')
    admin_auth.name = "Development Admin"
    admin_auth.email = "admin@ocw.local"

    unless admin_auth.user
      admin_user = OpenConferenceWare::User.create_from_authentication(admin_auth)
      admin_user.update_attributes(admin: true, biography: "I am mighty.")
    end

    mortal_auth = OpenConferenceWare::Authentication.find_or_initialize_by(provider: :developer, uid: 'mortal@ocw.local')
    mortal_auth.name = "Development User"
    mortal_auth.email = "mortal@ocw.local"

    unless mortal_auth.user
      mortal_user = OpenConferenceWare::User.create_from_authentication(mortal_auth)
      mortal_user.biography = "I'm ordinary."
      mortal_user.save!
    end
  end

  provider :openid, store: OpenID::Store::Filesystem.new(Rails.root.join('tmp'))
  provider :persona
end
