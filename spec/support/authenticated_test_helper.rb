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
    request.session[:user_id] = identity
  end

  def logout
    if request
      request.session[:user_id] = nil
    end
  end
end
