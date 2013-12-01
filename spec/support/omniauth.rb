OmniAuth.config.test_mode = true

module OmniAuthSpecHelper
  %w(user admin selector).each do |factory|
    define_method("#{factory}_auth_hash") do 
      OmniAuth::AuthHash.new({
        provider: 'open_id', 
        uid: "http://openconferenceware.org/factory/#{factory}",
        info: { name: factory }
      })
    end
  end

  def mock_sign_in(factory)
    create_mock_user(factory)
    OmniAuth.config.mock_auth[:open_id] = send("#{factory}_auth_hash")
    visit "/auth/open_id"
  end

  def create_mock_user(factory)
    auth_params = {provider: "open_id", uid: "http://openconferenceware.org/factory/#{factory}"}
    user = Authentication.where(auth_params).first
    unless user.present?
      user = create(factory)
      auth = create(:authentication, auth_params.merge(user: user))
    end

    return user
  end
end

RSpec.configure do |c|
  c.include OmniAuthSpecHelper
end
