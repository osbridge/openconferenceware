# This controller handles the login/logout function of the site.
class BrowserSessionsController < ApplicationController

  before_filter :assign_return_to, :only => [:index, :new, :admin]

  def index
    return redirect_to(login_path)
  end

  # Display mortal login form
  def new
  end

  # Display admin login form
  def admin
  end

  # Process login
  def create
    # Save the "remember_me" value as a cookie so it survives OpenID redirects.
    # Keep this cookie around for a few minutes so the user can complete the
    # OpenID login. When their login succeeds, they'll get a persistent
    # "auth_token" cookie that'll be used to do subsequent logins.
    if params[:remember_me]
      cookies[:remember_me] = { :value => "1", :expires => 10.minutes.from_now }
    end

    if (admin? || allow_arbitrary_logins?) && params[:login_as]
      if user = User.find_by_login(params[:login_as])
        self.current_user = user
        successful_login "Logged in as #{params[:login_as]}"
      else
        failed_login "Sorry, that login doesn't exist"
      end
    elsif using_open_id?
      open_id_authentication
    else
      password_authentication(params[:name], params[:password])
    end
  end

  # For some OpenID triggers a show rather than a create :(
  alias_method :show, :create

  # Logout
  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."

    # After logging out, try to return to the most sensible page: current
    # event's sessions or proposals, or default event's proposals.
    target_path = \
      if @event
        if @event.proposal_status_published?
          event_sessions_path(@event)
        else
          event_proposals_path(@event)
        end
      else
        proposals_path
      end

    redirect_back_or_default(target_path)
  end

protected

  # Allow logins without specifying a password or nounce? Used only in development and testing.
  def allow_arbitrary_logins?
    return %w[development preview test].include?(RAILS_ENV)
  end

  # The parameter name of "openid_url" is used rather than the Rails convention "open_id_url"
  # because that's what the specification dictates in order to get browser auto-complete working across sites
  def using_open_id?(identity_url = params[:openid_url]) #:doc:
    !identity_url.blank? || params[:open_id_complete]
  end
  # XXX Why did I have to manually add this method here? Wasn't it included before automatically?

  def password_authentication(name, password)
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      successful_login
    else
      failed_login "Sorry, that username/password doesn't work"
    end
  end

  def open_id_authentication
    identity_url = params[:openid_url]
    begin
      authenticate_with_open_id(identity_url, :optional => [:nickname, :email, :fullname]) do |result, identity_url, registration|
        if result.missing?
          failed_login "Sorry, the OpenID server couldn't be found. Is the URL correct?"
        elsif result.canceled?
          failed_login "OpenID verification was canceled. Don't cancel it or try another OpenID provider?"
        elsif result.failed?
          failed_login "Sorry, the OpenID verification failed. Try another OpenID provider?"
        elsif result.successful?
          if self.current_user = User.find_by_openid(identity_url)
            successful_login "Logged in successfully, welcome back"
          elsif self.current_user = User.create_from_openid!(identity_url, registration)
            successful_login "Logged in successfully, account created"
          else
            raise ArgumentError, "Invalid success result from OpenID: #{{:params => params, :result => result, :identity_url => identity_url, :registration => registration, :current_user => current_user}.inspect}"
          end
        else
          failed_login result.message
        end
      end
    rescue OpenIdAuthentication::InvalidOpenId
      failed_login "Sorry, that is not a valid OpenID login. Is the URL correct? Try another OpenID provider?"
    end
  end

private

  # Save the URL the user was on when they clicked login so that we can return them to that page once they're logged in.
  def assign_return_to
    session[:return_to] ||= request.referer
    return false
  end

  def successful_login(message="Logged in successfully")
    if cookies[:remember_me] == "1"
      cookies.delete(:remember_me)
      self.current_user.remember_me
      cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
    end
    flash[:notice] = message
    flash.keep
    redirect_back_or_default(proposals_path)
  end

  def failed_login(message)
    flash[:failure] = message
    redirect_to(params[:login_type] == "admin" ? admin_url : login_url)
  end

  # registration is a hash containing the valid sreg keys given above
  # use this to map them to fields of your user model
  def assign_registration_attributes!(registration)
    model_to_registration_mapping.each do |model_attribute, registration_attribute|
      unless registration[registration_attribute].blank?
        @current_user.send("#{model_attribute}=", registration[registration_attribute])
      end
    end
  end

  def model_to_registration_mapping
    { :login => 'nickname', :email => 'email', :display_name => 'fullname' }
  end

end
