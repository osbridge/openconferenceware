class ProposalsController < ApplicationController

  before_filter :login_required, :only => [:edit, :update, :destroy, :speaker_confirm, :speaker_decline, :proposal_login_required]
  before_filter :assert_current_event_or_redirect
  before_filter :assert_proposal_status_published, :only => [:sessions_index, :sessions_index_terse, :session_show]
  before_filter :assert_schedule_published, :only => [:schedule]
  before_filter :normalize_event_path_or_redirect, :only => [:index, :sessions_index, :schedule]
  before_filter :assert_anonymous_proposals, :only => [:new, :create]
  before_filter :assert_accepting_proposals, :only => [:new, :create]
  before_filter :assign_proposal_and_event, :only => [:show, :session_show, :edit, :update, :destroy, :speaker_confirm, :speaker_decline]
  before_filter :assert_record_ownership, :only => [:edit, :update, :destroy, :speaker_confirm, :speaker_decline]
  before_filter :assert_user_complete_profile, :only => [:new, :edit, :update]
  before_filter :assign_proposals_breadcrumb

  MAX_FEED_ITEMS = 50
  SESSION_RELATED_ACTIONS = ['sessions_index', 'session_show', 'schedule']

  # GET /proposals
  # GET /proposals.xml
  def index
    warn_about_incomplete_event

    @kind = :proposals

    assign_prefetched_hashes
    @proposals = Defer { @proposals_hash.values }

    unless params[:sort]
      params[:sort] = "submitted_at"
      params[:dir] = "desc"
    end

    respond_to do |format|
      format.html {
        add_breadcrumb @event.title, event_proposals_path(@event)
      }
      format.xml  {
        render :xml => @proposals
      }
      format.json {
        render :json => @proposals
      }
      format.atom {
        # index.atom.builder
        if @event_assignment == :assigned_to_param
          @cache_key = "proposals_atom,event_#{@event.id}"
          @proposals = Defer { @event.populated_proposals(:proposals).all(:order => "submitted_at desc", :limit => MAX_FEED_ITEMS) }
        else
          @cache_key = "proposals_atom,all"
          @proposals = Defer { Proposal.populated.all(:order => "submitted_at desc", :limit => MAX_FEED_ITEMS) }
        end
      }
      format.csv {
        records = @event.populated_proposals(@kind).all(:include => :comments)
        if admin?
          render :csv => records, :style => :admin
        else
          if schedule_visible?
            render :csv => records, :style => :schedule
          else
            render :csv => records
          end
        end
      }
    end
  end

  def sessions_index
    @kind = :sessions

    assign_prefetched_hashes
    @proposals = Defer { @sessions_hash.values }

    params[:sort] ||= "track"

    respond_to do |format|
      format.html {
        add_breadcrumb @event.title, event_proposals_path(@event)
        render :action => "index"
      }
      format.xml  {
        render :xml => @proposals
      }
      format.json {
        render :json => @proposals
      }
    end
  end

  def sessions_index_terse
    assign_prefetched_hashes
  end

  def schedule
    page_title 'Schedule'

    @schedule = Defer { Schedule.new(@event, admin?) }
    assign_prefetched_hashes

    respond_to do |format|
      format.html {
        @view_cache_key = "schedule,event_#{@event.id},admin_#{admin?}"
      }
      format.json {
        render :json => @schedule
      }
      format.xml {
        ### render :xml => @schedule
        render :xml => {:error => "XML output of schedule not yet supported"}, :status => :unprocessable_entity
      }
      format.ics {
        view_cache_key = "schedule,event_#{@event.id}.ics"
        data = Rails.cache.fetch_object(view_cache_key) {
          Proposal.to_icalendar(
            @schedule.items,
            :title => "#{@event.title}",
            :url_helper => lambda {|item| session_url(item)})
        }
        render :text => data
      }
    end
  end

  def session_show
    # @proposal and @event set via #assign_proposal_and_event filter
    @kind = :session
    unless @proposal.confirmed?
      @redirector = lambda {
        flash[:failure] = "This proposal is not a session."
        return redirect_to( proposal_path(@proposal) )
      }
    end
    return base_show
  end

  # GET /proposals/1
  # GET /proposals/1.xml
  def show
    # @proposal and @event set via #assign_proposal_and_event filter
    @kind = :proposal
    if @event.proposal_status_published? && @proposal.confirmed?
      @redirector = lambda {
        # flash[:notice] = "This proposal has been accepted as a session."
        flash.keep
        return redirect_to( session_path(@proposal) )
      }
    end
    return base_show
  end

  # GET /proposals/new
  # GET /proposals/new.xml
  def new
    add_breadcrumb @event.title, event_proposals_path(@event)
    add_breadcrumb "Create a proposal", new_event_proposal_path(@event)

    @proposal = Proposal.new(:agreement => false)

    # Set default track if only one was found.
    if event_tracks? && @event.tracks.size == 1
      @proposal.track = @event.tracks.first
    end

    # Set default session_type if only one was found.
    if event_session_types? && @event.session_types.size == 1
      @proposal.session_type = @event.session_types.first
    end

    if logged_in?
      @proposal.presenter = current_user.fullname
      @proposal.add_user(current_user)
    end
    @proposal.email = current_email

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @proposal }
      format.json { render :json => @proposal }
    end
  end

  # GET /proposals/1/edit
  def edit
    # @proposal set via #assign_proposal filter

    @event = @proposal.event
    add_breadcrumb @event.title, event_proposals_path(@event)
    add_breadcrumb @proposal.title, proposal_path(@proposal)
  end

  # POST /proposals
  # POST /proposals.xml
  def create
    if params[:commit] == "Login" && params[:openid_url]
      store_location(new_proposal_path)
      return redirect_to(open_id_complete_path(:openid_url => params[:openid_url]))
    end

    @proposal = Proposal.new(params[:proposal])
    @proposal.event = @event
    @proposal.add_user(current_user) if logged_in?
    @proposal.transition = transition_from_params if admin?

    manage_speakers_on_submit

    respond_to do |format|
      if params[:speaker_submit].blank? && params[:preview].nil? && @proposal.save
        format.html {
          page_title "Thank You!"
          # Display a page thanking users for submitting a proposal and telling them what to do next.
          render
        }
        format.xml  { render :xml => @proposal, :status => :created, :location => @proposal }
        format.json { render :json => @proposal, :status => :created, :location => @proposal }
      else
        @proposal.valid? if params[:preview]
        format.html { render :action => "new" }
        format.xml  { render :xml => @proposal.errors, :status => :unprocessable_entity }
        format.json { render :json => @proposal.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /proposals/1
  # PUT /proposals/1.xml
  def update
    # @proposal and @event set via #assign_proposal_and_event filter
    
    # If proposal title editing is locked, prevent non-admin from modifying title.
    if params[:proposal] && @event.proposal_titles_locked? && ! admin?
      params[:proposal].delete(:title)
    end

    if params[:start_time] && admin?
      if params[:start_time][:date].blank? || params[:start_time][:hour].blank? || params[:start_time][:minute].blank?
        @proposal.start_time = nil
      else
        @proposal.start_time = "#{params[:start_time][:date]} #{params[:start_time][:hour]}:#{params[:start_time][:minute]}"
      end
    end

    add_breadcrumb @event.title, event_proposals_path(@event)
    add_breadcrumb @proposal.title, proposal_path(@proposal)

    manage_speakers_on_submit

    respond_to do |format|
      if params[:speaker_submit].blank? && params[:preview].nil? && @proposal.update_attributes(params[:proposal])
        @proposal.transition = transition_from_params if admin?
        format.html {
          flash[:success] = 'Updated proposal.'
          redirect_to(@proposal)
        }
        format.xml  { head :ok }
        format.json { 
          render(
            :json => {
              :proposal_status => @proposal.status, 
              :_transition_control_html => render_to_string(:partial => '/proposals/transition_control.html.erb')
            }, 
            :status => :ok
          )
        }
      else
        if params[:preview]
          @proposal.attributes = params[:proposal]
          @proposal.valid?
        end
        format.html { render :action => "edit" }
        format.xml  { render :xml => @proposal.errors, :status => :unprocessable_entity }
        format.json { render :json => @proposal.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /proposals/1
  # DELETE /proposals/1.xml
  def destroy
    # @proposal and @event set via #assign_proposal_and_event filter

    @proposal.destroy
    flash[:success] = "Destroyed proposal: #{@proposal.title}"

    respond_to do |format|
      format.html { redirect_to(event_proposals_path(@proposal.event)) }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end

  def manage_speakers
    @proposal = get_proposal_for_speaker_manager(params[:id], params[:speakers])

    if params[:add]
      user = User.find(params[:add])
      @proposal.add_user(user)
    elsif params[:remove]
      user = User.find(params[:remove])
      @proposal.remove_user(user)
    end

    respond_to do |format|
      format.html { render :partial => "manage_speakers.html.erb", :layout => false }
    end
  end

  def search_speakers
    @proposal = get_proposal_for_speaker_manager(params[:id], params[:speakers])
    @matches = get_speaker_matches(params[:search])

    respond_to do |format|
      format.json { render :partial => "search_speakers.html.erb", :layout => false }
    end
  end

  def stats
    # Uses @event
  end

  # GET /proposals/1/login
  def proposal_login_required
    return redirect_to(proposal_path(params[:proposal_id]))
  end

  def speaker_confirm
    # @proposal and @event set via #assign_proposal_and_event filter
    if current_user_is_proposal_speaker? and @proposal.confirm!
      flash[:success] = 'Updated proposal. Thank you for confirming!'
    end
    redirect_to(@proposal)
  end

  def speaker_decline
    # @proposal and @event set via #assign_proposal_and_event filter
    if current_user_is_proposal_speaker? and @proposal.decline!
      flash[:success] = 'Updated proposal.'
    end
    redirect_to(@proposal)
  end

protected

  # Is this event accepting proposals? If not, redirect with a warning.
  def assert_accepting_proposals
    unless accepting_proposals? || admin?
      flash[:failure] = Snippet.content_for(:proposals_not_accepted_error)
      redirect_to @event ? event_proposals_path(@event) : proposals_path
    end
  end

  # Ensure that anonymous users are allowed to add proposals
  def assert_anonymous_proposals
    if logged_in?
      return false # Logged in users can always create
    else
      if anonymous_proposals?
        return false # Anonymous proposals are allowed
      else
        flash[:notice] = "Please login so you can create and manage proposals."
        store_location
        return redirect_to(login_path)
      end
    end
  end

  # Return the proposal and its assignment status for this request. The status
  # can be:
  # * :assigned_via_param
  # * :invalid_proposal
  # * :invalid_event
  def get_proposal_and_assignment_status
    if proposal = Proposal.lookup(params[:id].to_i) rescue nil
      if proposal.event
        return [proposal, :assigned_via_param]
      else
        return [proposal, :invalid_event]
      end
    else
      return [proposal, :invalid_proposal]
    end
  end

  def get_proposal_for_speaker_manager(proposal_id, speaker_ids_string)
    if proposal_id.blank? || proposal_id == "new_record"
      proposal = Proposal.new
      speaker_ids_string.split(',').each do |speaker|
        proposal.add_user(speaker)
      end
    else
      proposal = Proposal.find(proposal_id)
    end
    return proposal
  end

  # Assign @proposal and @event from parameters, or redirect with warnings.
  def assign_proposal_and_event
    @proposal, @proposal_assignment_status = get_proposal_and_assignment_status()
    case @proposal_assignment_status
    when :assigned_via_param
      @event = @proposal.event
      return false # Successfully found both @event and @proposal
    when :invalid_proposal
      flash[:failure] = "Sorry, that presentation proposal doesn't exist or has been deleted."
      return redirect_to(:action => :index)
    when :invalid_event
      flash[:failure] = "Sorry, no event was associated with proposal ##{@proposal.id}"
      return redirect_to(:action => :index)
    end
  end

  def assert_user_complete_profile
    if user_profiles? and logged_in? and not current_user.complete_profile?
      current_user.complete_profile = true
      if current_user.valid?
        current_user.save
      else
        flash[:notice] = "Please complete your profile before creating a proposal."
        store_location
        return redirect_to(edit_user_path(current_user, :require_complete_profile => true))
      end
    end
  end

  def assign_proposals_breadcrumb
    add_breadcrumb "Proposals", proposals_path
  end

  def manage_speakers_on_submit
    speakers = params[:speaker_ids].ergo.map(&:first)
    unless speakers.blank?
      speakers.each do |speaker|
        @proposal.add_user(speaker)
      end
    end
  end

  # Return the name of a transition (e.g., "accept") from a Proposal's params.
  def transition_from_params
    return params[:proposal].ergo[:transition]
  end

  # Return a sanitized Regexp for matching a speaker by name from the +query+ string.
  def get_speaker_matcher(query)
    string = query.gsub(/[[:punct:]]/, ' ').gsub(/\s{2,}/, ' ').strip
    return Regexp.new(Regexp.escape(string), Regexp::IGNORECASE)
  end

  # Return an array of speakers (User records) matching the +query+ string.
  def get_speaker_matches(query)
    if query.blank? || ! query.match(/\w+/)
      return []
    else
      matcher = get_speaker_matcher(query)
      return(User.complete_profiles.select{|u| u.fullname.ergo.match(matcher)} - @proposal.users)
    end
  end

  # Base method used for #show and #session_show
  def base_show
    if selector? && @event.accept_selector_votes?
      @selector_vote = @proposal.selector_votes.find_or_initialize_by_user_id(current_user.id)
    end

    unless defined?(@redirector)
      add_breadcrumb @event.title, event_proposals_path(@event)
      add_breadcrumb @proposal.title, proposal_path(@proposal)

      @profile = @proposal.profile
      @comment = Comment.new(:proposal => @proposal, :email => current_email)
      @display_comment_form = \
        # Admin can always leave comments
        admin? || (
          # Display comment form if the event is accepting proposals
          accepting_proposals? ||
          # or if the settings provide a toggle and the event is accepting comments
          (event_proposal_comments_after_deadline? && @event.accept_proposal_comments_after_deadline?)
        )
      @focus_comment = false
    end

    respond_to do |format|
      format.html { 
        if defined?(@redirector)
          @redirector.call
        else
          render :template => "/proposals/show" 
        end
      }
      format.xml  { render :xml  => @proposal }
      format.json { render :json => @proposal }
    end
  end

end
