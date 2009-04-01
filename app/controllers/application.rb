# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '56b4f0ad244d35b7e0d30ba0c5e1ae61'

  # Provide methods for checking SETTINGS succinctly
  include SettingsCheckersMixin

  # Provide faux routes, e.g., #tracks_path
  include FauxRoutesMixin

  # Provide access to page_title in controllers
  include PageTitleHelper

  # Setup authentication (e.g., login)
  include AuthenticatedSystem

  # Setup exception handling (e.g., what to do when exception raised)
  include ExceptionHandlingMixin

  # Setup breadcrumbs
  include BreadcrumbsMixin
  add_breadcrumbs(SETTINGS.breadcrumbs)

  # Setup theme
  layout "application"
  theme THEME_NAME # DEPENDENCY: lib/theme_reader.rb

  # Filters
  before_filter :assign_events
  before_filter :assign_current_event_without_redirecting

protected

  #---[ General ]---------------------------------------------------------

  # Return the current_user's email address
  def current_email
    (current_user != :false ? current_user.email : nil) || session[:email]
  end
  helper_method :current_email

  # Are we running in a development mode?
  def development_mode?
    return %w[development preview].include?(RAILS_ENV)
  end
  helper_method :development_mode?

  #---[ Access control ]--------------------------------------------------

  # Can the current user edit the current +record+?
  def can_edit?(record=nil)
    record ||= @proposal || @user
    raise ArgumentError, "No record specified" unless record

    if logged_in?
      if current_user.admin?
        true
      else
        # Normal user
        case record
        when Proposal
          # TODO Add setting to determine if users can alter their proposals after the accepting_proposals deadline passed.
          accepting_proposals?(record) && record.can_alter?(current_user)
        when User
          current_user == record
        else
          raise TypeError, "Unknown record type: #{record.class}"
        end
      end
    else
      false
    end
  end
  helper_method :can_edit?

  # Is the current user an admin?
  def admin?
    logged_in? && current_user.admin?
  end
  helper_method :admin?

  # Ensure user is an admin, or bounce them to the admin prompt.
  def require_admin
    admin? || access_denied
  end

  # Is this event accepting proposals?
  def accepting_proposals?(record=nil)
    event = \
      case record
      when Event then record
      when Proposal then record.event
      else @event
      end

    return event.ergo.accepting_proposals?
  end
  helper_method :accepting_proposals?

  #---[ Assign items ]----------------------------------------------------

  # Assign an @events variable for use by the layout when displaying available events.
  def assign_events
    @events = Event.lookup
  end

  # Return the event and a status which describes how the event was assigned. The status can be one of the following:
  # * :assigned_to_param
  # * :invalid_param
  # * :assigned_to_current
  # * :empty
  def get_current_event_and_assignment_status
    event = nil
    status = nil

    # Try finding event matching the :event_id given in the #params.
    event_id_key = controller_name == "events" ? :id : :event_id
    if key = params[event_id_key].ergo.to_i
      if event = Event.lookup(key)
        logit "assigned via #{event_id_key} to: #{key}"
        status = :assigned_to_param
        return [event, status]
      else
        logit "error, specified event_id_key '#{key}' was not found in database"
        invalid_param = params[event_id_key]
      end
    end

    # Try finding the current event.
    if event = Event.current
      logit "assigned to current event"
      if invalid_param
        status = :invalid_param
        return [event, status]
      else
        status = :assigned_to_current
        return [event, status]
      end
    end

    logit "error, no current event found"
    status = :empty
    return [event, status]
  end

  # Assign @event if it's not already set. Also set the
  # @event_assignment value to describe how the @event was assigned,
  # which can be one of the following values:
  # * :assigned_already
  # * Or any of the statuses described in
  #   #get_current_event_and_assignment_status
  def assign_current_event_without_redirecting
    invalid_param = false

    # Only assign event if one isn't already assigned.
    if @event
      logit "already assigned"
      @event_assignment = :assigned_already
    else
      @event, @event_assignment = get_current_event_and_assignment_status()
    end
    return false
  end

  # Ensure that @event is assigned (by #assign_current_event_without_redirecting).
  # If not, display an error or force the admin to create a new event.
  def assert_current_event_or_redirect
    case @event_assignment
    when :invalid_param
      flash[:failure] = "Couldn't find event, redirected to current event."
      flash.keep
      return redirect_to(event_path(@event))
    when :empty
      flash[:failure] = "No current event available. Admin needs to create one."
      if admin?
        # Allow admin to create an event.
        flash.keep
        return redirect_to(manage_events_path)
      else
        # Display a static error page.
        render :template => 'events/index.html.erb'
        return true # Cancel further processing
      end
    else
      return false
    end
  end

  # Redirect the user to the canonical event path if they're visiting a path that doesn't start with '/events'.
  def normalize_event_path_or_redirect
    if request.format.to_sym == :html
      if request.path.match(%r{^/events})
        return false
      else
        path = "/events/#{@event.id}/#{controller_name}/#{action_name == 'index' ? '' : action_name}"
        flash.keep
        return redirect_to(path)
      end
    else
      # Non-HTTP requests don't understand redirects, so leave these alone
      return false
    end
  end

end
