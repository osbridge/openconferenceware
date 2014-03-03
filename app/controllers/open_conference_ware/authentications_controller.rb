module OpenConferenceWare
  class AuthenticationsController < ApplicationController
    before_filter :require_auth_hash, only: [:create]

    # We need to accept a raw POST from an OmniAuth provider with no authenticity token.
    skip_before_filter :verify_authenticity_token, :only => :create

    def sign_in
      page_title "Sign In"
    end

    def sign_out
      cookies.delete :auth_token
      reset_session
      flash[:notice] = "You have been logged out."

      redirect_back_or_default
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

      redirect_back_or_default
    end

    def failure
      flash[:error] = params[:message]
      redirect_to sign_in_path
    end

    protected

    def auth_hash
      request.env['omniauth.auth']
    end

    def require_auth_hash
      redirect_to(sign_in_path) and return unless auth_hash
    end
  end
end
