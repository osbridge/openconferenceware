puts "[OCW] Running OpenConferenceWare seeds"
puts "[OCW] Creating snippets, if they don't exist"
OpenConferenceWare::Snippet.load_from_fixtures

if %w[development preview].include?(Rails.env)
  if ActiveRecord::Base.connection.table_exists?('open_conference_ware_authentications')
    puts "[OCW] Creating sample users for development"
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
  else
    puts "[OCW] The open_conference_ware_authentications table does not exist, please run `rake db:migrate`"
  end
else
  puts "[OCW] Not creating development users in the #{Rails.env} environment"
end
