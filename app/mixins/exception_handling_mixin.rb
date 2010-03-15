# = ExceptionHandlingMixin
#
# This mixin provides the application with exception handling:
# 1. Includes ExceptionNotifier plugin's methods
# 2. Provides attractive template views
# 3. Provides /br3ak action to test exception handling
#
# The exception notifier is enabled by default for the 'preview' and
# 'production' environments, but you can set the environmental variable
# EXCEPTION_NOTIFIER to '1' to enable it or '0' to disable it.
#
# The exception emails are enabled by default in environments other than 'test'
# and 'development', but you can set the environmental variable
# EXCEPTION_EMAILS to '1' to enable them or '0' to disable them.
#
# For example, enable the exception notifier for a 'development' server:
#   EXCEPTION_NOTIFIER=1 ./script/server
module ExceptionHandlingMixin

  include PageTitleHelper

  # Setup ExceptionNotifier plugin
  def self.included(mixee)
    if self.exception_notifier?
      Rails.logger.info('ExceptionHandlingMixin: Enabling exception handling')

      Rails.configuration.action_controller.consider_all_requests_local = false
      Rails.configuration.action_mailer.raise_delivery_errors = true

      mixee.send(:include, ExceptionNotifiable)
      mixee.send(:consider_all_requests_local=, false)
      mixee.local_addresses.clear

      mixee.send(:extend, Methods)
      mixee.send(:include, Methods)

      unless self.exception_emails?
        Rails.logger.info('ExceptionHandlingMixin: Disabling exception emails')
        ExceptionNotifier.exception_recipients = []
      end
    end
  end

  # Use the exception notifier?
  def self.exception_notifier?
    if ENV['EXCEPTION_NOTIFIER']
      return ENV['EXCEPTION_NOTIFIER'] == '1'
    else
      return %w[preview production].include?(RAILS_ENV)
    end
  end

  # Send emails if the exception notifier is enabled?
  def self.exception_emails?
    if ENV['EXCEPTION_EMAILS']
      return ENV['EXCEPTION_EMAILS'] == '1'
    else
      return ! %w[test development].include?(RAILS_ENV)
    end
  end

  module Methods
    # Overrides ApplicationController
    def local_request?
      return false
    end

    # Overrides ExceptionNotifiable
    def rescue_action_in_public(exception)
      @exception = exception

      case exception
      when ActionController::InvalidAuthenticityToken
        render_422
      else
        super(exception)
      end
    end

    # Render an exception for the given HTTP +code+ (e.g. 404) with a message (e.g. 'Not Found').
    #
    # Options:
    # * :status => Status message to use for title and HTTP status line. Defaults to code and message.
    # * :template => Template to render. Defaults to using the one matching the error code.
    def render_exception(code, message, opts={})
      status   = opts[:status]   || "#{code} #{message}"
      template = opts[:template] || "/#{code}.html.erb"

      begin
        page_title status
        respond_to do |type|
          type.html { render :status => status, :template => template }
          type.all  { render :status => status, :nothing  => true     }
        end
        return true
      rescue Exception => e
        @exception_handler_exception = e
        return false
      end
    end

    # Overrides ExceptionNotifiable
    def render_404
      render_exception(404, 'Not Found') or super
    end

    # Unique renderer
    def render_422
      render_exception(422, 'Unprocessable Entity')
    end

    # Overrides ExceptionNotifiable
    def render_500
      render_exception(500, 'Server Error') or super
    end

    # Action for testing 500 error
    def br3ak
      raise RuntimeError, "OMFG!!1!"
    end

    # Action for testing 404 error
    def m1ss
      raise ActiveRecord::RecordNotFound, "OH NOES!!1!"
    end
  end
end
