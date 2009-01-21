class ProposalsController < ApplicationController

  before_filter :login_required,               :only => [:edit, :update, :destroy]
  before_filter :assign_current_event,         :only => [:new, :create]
  before_filter :assert_anonymous_proposals,   :only => [:new, :create]
  before_filter :assert_accepting_proposals,   :only => [:new, :create]
  before_filter :assign_proposal_and_event,    :only => [:show, :edit, :update, :destroy]
  before_filter :assert_proposal_ownership,    :only => [:edit, :update, :destroy]
  before_filter :assert_user_complete_profile, :only => [:new, :edit, :update]
  before_filter :assign_proposals_breadcrumb

  MAX_FEED_ITEMS = 20

  # GET /proposals
  # GET /proposals.xml
  def index
    case request.format.to_sym
    when :atom, :json, :xml
      @event = params[:event_id] ? Event.lookup(params[:event_id].to_i) : nil
    else
      return if assign_current_event
    end
    @proposals = @event ? @event.lookup_proposals : Proposal.lookup
    
    if %w(title track).include?(params[:sort])
      @proposals = @proposals.sort_by{|proposal| proposal.send(params[:sort])}
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
        @proposals = @proposals[0..MAX_FEED_ITEMS]
      }
      format.csv {
        # TODO support profile in proposal or user
        # TODO how to support multiple speakers!?
        buffer = StringIO.new
        CSV::Writer.generate(buffer) do |csv|
          fields = [
            :id,
            :submitted_at,
            :presenter,
            :affiliation,
            :website,
            :biography,
            :title,
            :description,
          ]
          if admin?
            fields << :email
            fields << :note_to_organizers
            fields << :comments_text
          end
          csv << fields.map{|field| field.to_s}
          for proposal in @proposals
            csv << fields.map{|field| value = proposal[field]; field == :created_at ? value.localtime.to_s(:date_time12) : value }
          end
        end
        buffer.rewind
        render :text => buffer.read
      }
    end
  end

  # GET /proposals/1
  # GET /proposals/1.xml
  def show
    # @proposal and @event set via #assign_proposal_and_event filter

    add_breadcrumb @event.title, event_proposals_path(@event)
    add_breadcrumb @proposal.title, proposal_path(@proposal)

    # TODO extract into filter?
    @profile = \
      if multiple_presenters?
        false
      else
        if user_profiles?
          @proposal.user
        else
          @proposal
        end
      end
    @comment = Comment.new(:proposal => @proposal, :email => current_email)
    @display_comment = (! params[:commented] && ! can_edit? && accepting_proposals?) || admin?
    @focus_comment = false

    # TODO do not include private fields in the json/xml exports
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @proposal }
      format.json { render :json => @proposal }
    end
  end

  # GET /proposals/new
  # GET /proposals/new.xml
  def new
    add_breadcrumb @event.title, event_proposals_path(@event)
    add_breadcrumb "Create a proposal", new_event_proposal_path

    @proposal = Proposal.new
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
      #return render_component(:controller => "sessions", :action => "create", :openid_url => params[:openid_url])
      return redirect_to(url_for(:controller => "sessions", :action => "create", :openid_url => params[:openid_url]))
    end

    @proposal = Proposal.new(params[:proposal])
    @proposal.event = @event
    @proposal.users << current_user if logged_in?

    manage_speakers

    respond_to do |format|
      if params[:commit] && @proposal.save
        flash[:success] = 'Created proposal.'
        format.html { redirect_to(@proposal) }
        format.xml  { render :xml => @proposal, :status => :created, :location => @proposal }
        format.json { render :json => @proposal, :status => :created, :location => @proposal }
      else
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

    add_breadcrumb @event.title, event_proposals_path(@event)
    add_breadcrumb @proposal.title, proposal_path(@proposal)

    manage_speakers

    respond_to do |format|
      if params[:commit] && @proposal.update_attributes(params[:proposal])
        flash[:success] = 'Updated proposal.'
        format.html { redirect_to(@proposal) }
        format.xml  { head :ok }
        format.json { head :ok }
      else
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

protected

  # Is this event accepting proposals? If not, redirect with a warning.
  def assert_accepting_proposals
    unless accepting_proposals?
      flash[:failure] = Snippet.content_for(:proposals_not_accepted_error)
      redirect_to @event ? event_proposals_path(@event) : proposals_path
    end
  end

  # Assert that #current_user can edit @proposal.
  def assert_proposal_ownership
    if admin?
      return false # admin can always edit
    else
      if accepting_proposals?
        if can_edit?
          return false # current_user can edit
        else
          flash[:failure] = "Sorry, you can't alter proposals that aren't yours."
          return redirect_to(proposal_path(@proposal))
        end
      else
        # TODO allow people to edit proposals after deadline IF there's a process that marks them as approved/rejected/etc.
        flash[:failure] = "You cannot edit proposals after the submission deadline."
        return redirect_to(@event ? event_proposals_path(@event) : proposals_path)
      end
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

  # Assign @proposal from parameters, or redirect to index.
  def assign_proposal_and_event
    if @proposal = Proposal.lookup(params[:id].to_i) rescue nil
      if @event = @proposal.event
        return false # Successfully found both @event and @proposal
      else
        flash[:failure] = "Sorry, no event was associated with proposal ##{@proposal.id}"
        return redirect_to(:action => :index)
      end
    else
      flash[:failure] = "Sorry, that presentation proposal doesn't exist or has been deleted."
      return redirect_to(:action => :index)
    end
  end

  def assert_user_complete_profile
    if user_profiles? and logged_in? and not current_user.complete_profile?
      flash[:notice] = "Please complete your profile before creating a proposal."
      store_location
      return redirect_to(edit_user_path(current_user, :require_complete_profile => true))
    end
  end

  def assign_proposals_breadcrumb
    add_breadcrumb "Proposals", proposals_path
  end

  def other_completed_profiles
    return (User.complete_profiles - @proposal.users).map{|user| [user.label_with_id, user.id]}
  end
  helper_method :other_completed_profiles

  def manage_speakers
    # TODO make this ajax
    # TODO add searching ajax to limit content of dropdown
    # TODO add invite mechanism somewhere
    @focus_speakers = false
    speakers = params[:speaker_ids].ergo.map(&:first)
    unless speakers.blank?
      speakers.each do |speaker|
        @proposal.add_user(speaker)
      end
    end
    if params[:add_speaker]
      @focus_speakers = true
      if params[:speaker][:id].blank?
        flash[:failure] = "Please select a speaker to add."
      else
        user = User.find(params[:speaker][:id])
        flash[:success] = "Added speaker to proposal: #{user.fullname}"
        @proposal.add_user(user)
      end
    elsif params[:remove_speaker]
      @focus_speakers = true
      if @proposal.users.size > 1
        user = User.find(params[:remove_speaker])
        @proposal.users.delete(user)
        flash[:success] = "Removed speaker from proposal: #{user.fullname}"
      else
        flash[:failure] = "You cannot delete the last speaker from a proposal"
      end
    end
  end

end
