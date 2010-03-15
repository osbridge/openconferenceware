# = ExceptionHandlingMixin
#
# This mixin provides application with exception handling:
# 1. Includes ExceptionNotifier plugin's methods
# 2. Provides attractive template views
# 3. Provides /br3ak action to test exception handling
module ExceptionHandlingMixin

  include PageTitleHelper

  # Notify on exceptions if Rails environment is either 'preview' or
  # 'production', or if 'NOTIFY_ON_EXCEPTIONS' environmental variable is set.
  NOTIFY_ON_EXCEPTIONS = ['preview', 'production'].include?(RAILS_ENV) || ENV['NOTIFY_ON_EXCEPTIONS']
  NOTIFY_ON_AUTHENTICY_EXCEPTIONS = ENV['NOTIFY_ON_AUTHENTICY_EXCEPTIONS']

  # Setup ExceptionNotifier plugin
  def self.included(mixee)
    if NOTIFY_ON_EXCEPTIONS
      Rails.configuration.action_controller.consider_all_requests_local = false
      Rails.configuration.action_mailer.raise_delivery_errors = true
      mixee.send(:include, ExceptionNotifiable)
      mixee.local_addresses.clear

      mixee.send(:extend, Methods)
      mixee.send(:include, Methods)
    end
  end

  module Methods
    # Overrides ExceptionNotifiable
    def rescue_action_in_public(exception)
      @exception = exception

      case exception
      when ActionController::InvalidAuthenticityToken
        render_422

        # Send emails when encountering InvalidAuthenticityToken errors?
        if NOTIFY_ON_AUTHENTICY_EXCEPTIONS
          deliverer = self.class.exception_data
          data = case deliverer
            when nil then {}
            when Symbol then send(deliverer)
            when Proc then deliverer.call(self)
          end

          ExceptionNotifier.deliver_exception_notification(exception, self,
            request, data)
        end
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
