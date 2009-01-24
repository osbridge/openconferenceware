# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '56b4f0ad244d35b7e0d30ba0c5e1ae61'

  # Provide methods for checking SETTINGS succinctly
  include SettingsCheckersMixin

  # Setup faux routes to TracksController, e.g., #tracks_path
  include TracksFauxRoutesMixin

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

protected

  #---[ General ]---------------------------------------------------------

  # Return the current_user's email address
  def current_email
    (current_user != :false ? current_user.email : nil) || session[:email]
  end
  helper_method :current_email

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
    admin? || access_denied('/sessions', 'admin')
  end

  # Is this event accepting proposals?
  def accepting_proposals?(record=nil)
    event = \
      case record
      when Event then record
      when Proposal then record.event
      else nil
      end

    unless event
      if assign_current_event
        # An error or redirect was detected, therefore we're not accepting proposals
        return false
      else
        event = @event
      end
    end

    return event.accepting_proposals?
  end
  helper_method :accepting_proposals?

  #---[ Assign items ]----------------------------------------------------

  # Assign an @events variable for use by the layout when displaying available events.
  def assign_events
    @events = Event.lookup || []
  end

  # Assign @event if it's not already set. Return true if redirected or failed,
  # false if assigned event for normal processing. WARNING: performs redirects
  # and sets #flash.
  def assign_current_event
    # Only assign event if one isn't already assigned.
    if @event
      RAILS_DEFAULT_LOGGER.debug("assign_current_event: @event already assigned")
      return false
    end

    # Try finding event matching the :event_id given in the #params.
    event_id_key = controller_name == "events" ? :id : :event_id
    if key = params[event_id_key].ergo.to_i
      if @event = Event.lookup(key)
        RAILS_DEFAULT_LOGGER.debug("assign_current_event: @event assigned via event_id_key to: #{key}")
        return false
      else
        RAILS_DEFAULT_LOGGER.debug("assign_current_event: @event specified by event_id_key not found in database: #{key}")
        flash[:failure] = "Couldn't find event '#{params[event_id_key]}', redirected to current event."
      end
    end

    # Try finding the current event.
    if @event = Event.current
      flash.keep
      RAILS_DEFAULT_LOGGER.debug("assign_current_event: @event assigned via default and redirecting to: #{@event.id}")
      # TODO this should be generalized so it can redirect to proposals, tracks, sessions, etc
      return redirect_to(event_proposals_path(@event))
    end

    # Nuts, there must be no events in the database.
    flash[:failure] = "No current event available. Admin needs to create one."
    RAILS_DEFAULT_LOGGER.debug("assign_current_event: no current event available")
    if admin?
      # Allow admin to create an event.
      flash.keep
      return redirect_to(manage_events_path)
    else
      # Display a static error page.
      render :template => 'events/index.html.erb'
      return true # Cancel further processing
    end
  end

end
