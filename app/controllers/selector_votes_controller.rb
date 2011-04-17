class SelectorVotesController < ApplicationController
  before_filter :require_admin, :only => [:index, :new, :edit, :destroy]
  before_filter :require_selector, :only => [:create, :update]

  # GET /selector_votes
  # GET /selector_votes.xml
  def index
    unless @event
      flash[:failure] = "Can't display selector votes without an event!"
      return redirect_back_or_to(root_path)
    end

    # Sort using Ruby because overriding the sorting on a Proposal with includes produces very inefficient SQL.
    @proposals = \
      begin
        proposals = @event.proposals.all(:include => [:selector_votes, :comments, :users, :user_favorites])
        case params[:order]
        when 'title'
          proposals.sort_by { |proposal| proposal.title.downcase }
        when 'vote_points'
          proposals.sort_by { |proposal| - proposal.selector_vote_points }
        when 'votes_count'
          proposals.sort_by { |proposal| - proposal.selector_votes.size }
        when 'favorites_count'
          proposals.sort_by { |proposal| - proposal.user_favorites.size }
        when 'id', '', nil
          proposals.sort_by { |proposal| proposal.created_at }
        else # includes 'id'
          flash[:failure] = "Unknown order: #{h(params[:order])}"
          proposals.sort_by { |proposal| proposal.created_at }
        end
      end

    respond_to do |format|
      format.html
      format.csv { render :csv => @proposals, :style => :selector_votes }
    end
  end

  # POST /selector_votes
  # POST /selector_votes.xml
  def create
    @selector_vote = SelectorVote.new(params[:selector_vote])
    set_user_on_selector_vote

    respond_to do |format|
      if @selector_vote.save
        flash[:success] = 'Vote created!'
        format.html { redirect_to_next_proposal }
        format.xml  { render :xml => @selector_vote, :status => :created, :location => @selector_vote }
      else
        flash[:failure] = @selector_vote.errors.full_messages.map {|o| "#{o}."}.join(" ")
        format.html { redirect_to(@selector_vote.proposal) }
        format.xml  { render :xml => @selector_vote.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /selector_votes/1
  # PUT /selector_votes/1.xml
  def update
    @selector_vote = SelectorVote.find(params[:id])
    set_user_on_selector_vote

    respond_to do |format|
      if @selector_vote.update_attributes(params[:selector_vote])
        flash[:success] = 'Vote updated!'
        format.html { redirect_to_next_proposal }
        format.xml  { head :ok }
      else
        flash[:failure] = @selector_vote.errors
        format.html { redirect_to(@selector_vote.proposal) }
        format.xml  { render :xml => @selector_vote.errors, :status => :unprocessable_entity }
      end
    end
  end

  protected

  def set_user_on_selector_vote
    @selector_vote.user = current_user
  end

  def redirect_to_next_proposal
    if next_proposal = @selector_vote.proposal.next_proposal
      redirect_to(next_proposal)
    else
      flash[:success] = "You've voted on the last proposal!"
      redirect_to(@selector_vote.proposal.event)
    end
  end
end
