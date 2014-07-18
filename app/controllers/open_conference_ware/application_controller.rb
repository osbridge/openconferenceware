module OpenConferenceWare
  # Filters added to this controller apply to all controllers in the application.
  # Likewise, all the methods added will be available for all controllers.

  class ApplicationController < ActionController::Base

    helper :all # include all helpers, all the time

    # See ActionController::RequestForgeryProtection for details
    # Uncomment the :secret if you're not using the cookie session store
    protect_from_forgery # secret: '56b4f0ad244d35b7e0d30ba0c5e1ae61'

    # Provide methods for checking settings succinctly
    include SettingsCheckersMixin

    # Provide faux routes, e.g., #tracks_path
    include FauxRoutesMixin

    # Provide access to page_title in controllers
    include PageTitleHelper

    # Setup breadcrumbs
    include BreadcrumbsMixin
    add_breadcrumbs(OpenConferenceWare.breadcrumbs)

    # Filters
    before_filter :assign_events
    before_filter :assign_current_event_without_redirecting
    before_filter :log_the_current_user
    before_filter :log_the_session

    rescue_from ActionController::UnknownFormat do |e|
      render(text: 'Not Found', status: 404)
    end

    #---[ Authentication ]--------------------------------------------------

    # Store the given user in the session.
    def current_user=(new_user)
      session[:user_id] = (new_user.nil? || new_user.is_a?(Symbol)) ? nil : new_user.id
      @current_user = new_user
    end

    # Accesses the current user from the session.
    def current_user
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    rescue ActiveRecord::RecordNotFound
      reset_session
    end
    helper_method :current_user

    # Returns true or false if the user is logged in.
    # Preloads @current_user with the user model if they're logged in.
    def logged_in?
      !!current_user
    end
    helper_method :logged_in?

    # Filter method to enforce a login requirement.
    def authentication_required
      logged_in? || access_denied(message: "Please sign in to access the requested page.")
    end

    # Redirect as appropriate when an access request fails.
    def access_denied(opts={})
      message = opts[:message] || "Access denied, please sign in with enough privileges to complete that operation."
      fallback_url = opts[:fallback_url] || opts[:fallback] || sign_in_path

      store_location
      redirect_to fallback_url, alert: message
    end

    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location(path=nil)
      session[:return_to] = path || request.fullpath
    end

    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_default(default=nil)
      redirect_to(session[:return_to] || default || default_path)
      session[:return_to] = nil
    end
    alias_method :redirect_back_or_to, :redirect_back_or_default

    def default_path
      if @event
        if @event.proposal_status_published?
          event_sessions_path(@event)
        else
          event_proposals_path(@event)
        end
      else
        proposals_path
      end
    end

  protected

    #---[ General ]---------------------------------------------------------

    # Return the current User record or a nil if not logged in.
    def current_user_or_nil
      return(current_user.kind_of?(User) ? current_user : nil)
    end
    helper_method :current_user_or_nil

    # Return the current_user's email address, from either the currently-logged
    # in user or the cookie, else nil.
    def current_email
      return(current_user_or_nil.try(:email) || session[:email])
    end
    helper_method :current_email

    # Return a cache key for the currently authenticated or anonymous user.
    def current_user_cache_key
      return current_user_or_nil.try(:id) || -1
    end
    helper_method :current_user_cache_key

    # Return a cache key for the current event.
    def current_event_cache_key
      return @event.try(:id) || -1
    end
    helper_method :current_event_cache_key

    # Are we running in a development mode?
    def development_mode?
      return %w[development preview].include?(Rails.env)
    end
    helper_method :development_mode?

    def event_schedule?
      proposal_start_times? && proposal_statuses? && event_rooms?
    end
    helper_method :event_schedule?

    def schedule_visible?
      (@event.schedule_published? || admin?) && event_schedule?
    end
    helper_method :schedule_visible?

    # Flash notification levels allowed by #notify.
    NOTIFY_LEVELS = Set.new([:notice, :success, :failure])

    # Sets or appends the flash notification.
    #
    # Arguments:
    # * level: Symbol name of the notificaiton level, e.g. "failure".
    # * message: String message to display.
    def notify(level, message)
      level = level.to_sym
      raise ArgumentError, "Invalid flash notification level: #{level}" unless NOTIFY_LEVELS.include?(level)
      flash[level] = "#{flash[level]} #{message}".strip.html_safe
    end

    #---[ Access control ]--------------------------------------------------

    # Can the current user edit the current +record+?
    def can_edit?(record)
      raise ArgumentError, "No record specified" unless record

      if logged_in?
        if current_user.admin?
          true
        else
          # Normal user
          case record
          when Proposal
            # FIXME Add setting to determine if users can alter their proposals after the accepting_proposals deadline passed.
            ### accepting_proposals?(record) && record.can_alter?(current_user)
            record.can_alter?(current_user)
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

    def current_role
      (logged_in? && current_user.role) || :default
    end
    helper_method :current_role

    # Ensure user is an admin, or bounce them to the admin prompt.
    def require_admin
      admin? || access_denied(message: "You must have administrator privileges to access the requested page.")
    end

    def current_user_is_proposal_speaker?
      if logged_in?
        return @proposal.users.include?(current_user)
      end
      return false
    end
    helper_method :current_user_is_proposal_speaker?

    # Is this event accepting proposals?
    def accepting_proposals?(record=nil)
      event = \
        case record
        when Event then record
        when Proposal then record.event
        else @event
        end

      return event.try(:accepting_proposals?)
    end
    helper_method :accepting_proposals?

    def selector?
      logged_in? && current_user.selector?
    end
    helper_method :selector?

    def require_selector
      selector? || access_denied(message: "You must be part of the selection committee to access the requested page.")
    end

    #---[ Logging ]---------------------------------------------------------

    def log_the_current_user
      Rails.logger.info("User: #{current_user.id}, #{current_user.label}") if current_user_or_nil
    end

    def log_the_session
      Rails.logger.info("Session: #{session.to_hash.inspect}") if session.respond_to?(:data)
    end

    #---[ Assign items ]----------------------------------------------------

    # Assign an @events variable for use by the layout when displaying available events.
    def assign_events
      @events = Event.all
    end

    # Return the event and a status which describes how the event was assigned. The status can be one of the following:
    # * :assigned_to_param
    # * :invalid_param
    # * :invalid_proposal_event
    # * :assigned_to_current
    # * :empty
    def get_current_event_and_assignment_status
      invalid = false

      # Try finding event using params:
      event_id_key = controller_name == "events" ? :id : :event_id
      if key = params[event_id_key]
        if event = Event.find_by_slug(key)
          return [event, :assigned_to_param]
        else
          logger.info "error, couldn't find event from key: #{key}"
          invalid = :invalid_param
        end
      end

      # Try finding event using proposal:
      if controller_name == "proposals" && params[:id]
        if proposal = Proposal.find_by_id(params[:id])
          if proposal.event
            return [proposal.event, :assigned_to_param]
          else
            logger.info "error, couldn't find event from Proposal ##{proposal.id}"
            invalid = :invalid_proposal_event
          end
        end
      end

      # Try finding the current event.
      if event = Event.current
        logger.info "assigned to current event"
        if invalid
          return [event, invalid]
        else
          return [event, :assigned_to_current]
        end
      end

      logger.info "error, no current event found"
      return [nil, :empty]
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
        logger.info "already assigned"
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
      when :invalid_proposal_event
        flash[:failure] = "Invalid proposal has no event, redirecting to current event's proposals."
        flash.keep
        return redirect_to(event_proposals_path(@event))
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
          render template: 'open_conference_ware/events/index'
          return true # Cancel further processing
        end
      else
        return false
      end
    end

    # Redirect the user to the canonical event path if they're visiting a path that doesn't start with '/events'.
    def normalize_event_path_or_redirect
      # When running under a prefix (e.g., "thin --prefix /omg start"), this value will be set to "/omg", else "".
      if request.format.to_sym == :html
        if request.path.match(%r{^#{OpenConferenceWare.mounted_path("/events")}})
          return false
        else
          if controller_name == "proposals" && action_name == "sessions_index"
            path = event_sessions_path(@event)
          elsif controller_name == "proposals" && action_name == "schedule"
            path = event_schedule_path(@event)
          else
            path = OpenConferenceWare.mounted_path("/events/#{@event.to_param}/#{controller_name}#{action_name == 'index' ? '' : "/#{action_name}" }")
          end
          flash.keep
          return redirect_to(path)
        end
      else
        # Non-HTTP requests don't understand redirects, so leave these alone
        return false
      end
    end

    # Ensure that the proposal status is defined, else redirect back to proposals
    def assert_proposal_status_published
      display = false
      if @event.proposal_status_published?
        display = true
      else
        if admin?
          display = true
          flash[:notice] = "Session information has not yet been published, only admins can see this page."
        end
      end
      unless display
        flash[:failure] = "Session information has not yet been published for this event."
        return redirect_to((params[:id] && request.path.include?("session")) ? proposal_path(params[:id]) : event_proposals_path(@event))
      end
    end

    # Ensure that the schedule is published
    def assert_schedule_published
      display = admin? || schedule_visible?
      flash[:notice] = "The schedule has not yet been published, only admins can see this page." if admin? && !schedule_visible?

      unless display
        flash[:failure] = "The schedule has not yet been published for this event."
        return redirect_to(@event.proposal_status_published? ? event_sessions_path(@event) : event_proposals_path(@event))
      end
    end

    # Sets @user based on params[:id] and adds related breadcrumbs.
    def assert_user
      case self
      when UsersController
        user_id = params[:id]
      when UserFavoritesController
        user_id = params[:user_id]
      else
        raise TypeError
      end

      if user_id == "me"
        if logged_in?
          @user = current_user
        else
          return access_denied(message: "Please sign in to access your user profile.")
        end
      else
        begin
          @user = User.find(user_id)
        rescue ActiveRecord::RecordNotFound
          flash[:failure] = "User not found or deleted"
          return redirect_to(users_path)
        end
      end

      # TODO Move breadcrumbs to filters/actions that rely on user.
      add_breadcrumb "Users", users_path
      add_breadcrumb @user.label, user_path(@user)
      add_breadcrumb "Edit" if ["edit", "update"].include?(action_name)
    end

    # Assert that #current_user can edit record.
    def assert_record_ownership
      case self
      when ProposalsController
        record = @proposal
      when UsersController, UserFavoritesController
        record = @user
        failure_message = "Sorry, you can't edit other users."
      else
        raise TypeError
      end

      if admin?
        return false # admin can always edit
      else
        if can_edit?(record)
          return false # current_user can edit
        else
          flash[:failure] = failure_message ||= "Sorry, you can't edit #{record.class.name.pluralize.downcase} that aren't yours."
          return redirect_to(record)
        end
      end
    end

    # OMFG HORRORS!!1!
    def assign_prefetched_hashes
      @users                    = Defer { @event.users }
      @users_hash               = Defer { Hash[@users.map{|t| [t.id, t]}] }
      @speakers                 = Defer { @event.speakers }
      @speakers_hash            = Defer { Hash[@speakers.map{|t| [t.id, t]}] }
      @tracks_hash              = Defer { Hash[@event.tracks.order("title ASC").map{|t| [t.id, t]}] }
      @rooms_hash               = Defer { Hash[@event.rooms.map{|t| [t.id, t]}] }
      @session_types_hash       = Defer { Hash[@event.session_types.map{|t| [t.id, t]}] }
      @proposals_hash           = Defer { Hash[@event.proposals.order("submitted_at DESC").includes(:track, :session_type).map{|t| [t.id, t]}] }
      @sessions_hash            = Defer { Hash[@event.proposals.confirmed.order("submitted_at DESC").includes(:track, :session_type).map{|t| [t.id, t]}] }
      @users_and_proposals      = Defer { ActiveRecord::Base.connection.select_all(%{select open_conference_ware_proposals_users.user_id, open_conference_ware_proposals_users.proposal_id from open_conference_ware_proposals_users, open_conference_ware_proposals where open_conference_ware_proposals_users.proposal_id = open_conference_ware_proposals.id and open_conference_ware_proposals.event_id = #{@event.id}}) }
      @users_and_sessions       = Defer { ActiveRecord::Base.connection.select_all(%{select open_conference_ware_proposals_users.user_id, open_conference_ware_proposals_users.proposal_id from open_conference_ware_proposals_users, open_conference_ware_proposals where open_conference_ware_proposals_users.proposal_id = open_conference_ware_proposals.id and open_conference_ware_proposals.status = 'confirmed' and open_conference_ware_proposals.event_id = #{@event.id}}) }
      @users_for_proposal_hash  = Defer { @users_and_proposals.inject({}){|s,v| (s[v["proposal_id"].to_i] ||= Set.new) << @users_hash[v["user_id"].to_i]; s} }
      @sessions_for_user_hash   = Defer { @users_and_sessions.inject({}){|s,v| (s[v["user_id"].to_i] ||= Set.new) << @sessions_hash[v["proposal_id"].to_i]; s} }
      @proposals_for_user_hash  = Defer { @users_and_proposals.inject({}){|s,v| (s[v["user_id"].to_i] ||= Set.new) << @proposals_hash[v["proposal_id"].to_i]; s} }
      @user_favorites_count_for_user_hash = Defer { ActiveRecord::Base.connection.select_all("select user_id, count(proposal_id) as favorites from open_conference_ware_user_favorites group by user_id").inject({}){|s,v| s[v["user_id"].to_i] = v["favorites"].to_i; s} }
    end

    # Warn admin to create event's session type and track if needed.
    def warn_about_incomplete_event
      if @event
        if event_tracks? && @event.tracks.size == 0
          if admin?
            notify :notice, "This event needs a track, you should #{view_context.link_to 'create one', new_event_track_path(@event)}.".html_safe
          else
            notify :failure, "This event has no tracks, an admin must create at least one."
          end
        end

        if event_session_types? && @event.session_types.size == 0
          if admin?
            notify :notice, "This event needs a session type, you should #{view_context.link_to 'create one', new_event_session_type_path(@event)}.".html_safe
          else
            notify :failure, "This event has no session types, an admin must create at least one."
          end
        end
      end
    end
  end
end
