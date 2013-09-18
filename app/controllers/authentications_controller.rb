class AuthenticationsController < ApplicationController
  before_filter :require_auth_hash, :only => [:create]

  def sign_in
    page_title "Sign In"
  end

  def sign_out
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

  def create
    @authentication = Authentication.find_and_update_or_create_from_auth_hash(auth_hash)

    if @authentication.user
      self.current_user = @authentication.user
    elsif logged_in?
      @authentication.user = current_user
      @authentication.save
    else
      self.current_user = User.create_from_authentication(@authentication)
    end

    redirect_to root_path
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end

  def require_auth_hash
    redirect_to(sign_in_path) and return unless auth_hash
  end
end
