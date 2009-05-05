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
    # Overrides exception_notification/lib/exception_notifiable.rb
    def rescue_action_in_public(exception)
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

    # Overrides exception_notification/lib/exception_notifiable.rb
    def render_404
      begin
        page_title "404 Not Found"
        respond_to do |type|
          type.html { render :template => "/404.html.erb", :status => "404 Not Found" }
          type.all  { render :nothing => true, :status => "404 Not Found" }
        end
      rescue
        super
      end
    end

    # Overrides exception_notification/lib/exception_notifiable.rb
    def render_422
      begin
        page_title "422 Unprocessable Entity"
        respond_to do |type|
          type.html { render :template => "/422.html.erb", :status => "422 Unprocessable Entity" }
          type.all  { render :nothing => true, :status => "422 Unprocessable Entity" }
        end
      rescue
        super
      end
    end

    # Overrides exception_notification/lib/exception_notifiable.rb
    def render_500
      begin
        page_title "500 Server Error"
        respond_to do |type|
          type.html { render :template => "/500.html.erb", :status => "500 Error" }
          type.all  { render :nothing => true, :status => "500 Error" }
        end
      rescue
        super
      end
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
