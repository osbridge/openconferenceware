class CreateOpenIdAuthenticationsFromExistingUsers < ActiveRecord::Migration
  def up
    say_with_time "Creating OpenID authentications for existing OpenID users" do
      User.where(using_openid: true).find_each do |user|
        user.authentications.create(
          uid: user.login,
          provider: 'open_id',
          name: user.fullname,
          email: user.email
        )
      end
    end
  end
end
