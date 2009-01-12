module AuthenticatedTestHelper
  # Sets the current user in the session from the user fixtures.
  def login_as(user)
    identity = \
      case user
      when User
        user.id
      when String
        users(user.to_sym).id
      when Symbol
        users(user).id
      when Fixnum
        user
      when NilClass
        nil
      else
        raise TypeError, "Can't login as type: #{user.class}"
      end
    request.session[:user] = identity
  end

  def authorize_as(user)
    request.env["HTTP_AUTHORIZATION"] = user ? %{Basic #{Base64.encode64("#{users(user).login}:test")}} : nil
  end

  def logout
    if request
      request.session[:user] = nil
      request.env["HTTP_AUTHORIZATION"] = nil
    end
  end
end
