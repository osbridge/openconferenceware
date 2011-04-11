class SelectorVotesController < ApplicationController
  before_filter :require_admin, :only => [:index, :new, :edit, :destroy]
  before_filter :require_selector, :only => [:create, :update]

  # GET /selector_votes
  # GET /selector_votes.xml
  def index
    raise NotImplementedError
=begin
    @selector_votes = SelectorVote.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @selector_votes }
    end
=end
  end

  # GET /selector_votes/1
  # GET /selector_votes/1.xml
  def show
    raise NotImplementedError
=begin
    @selector_vote = SelectorVote.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @selector_vote }
    end
=end
  end

  # GET /selector_votes/new
  # GET /selector_votes/new.xml
  def new
    raise NotImplementedError

=begin
    @selector_vote = SelectorVote.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @selector_vote }
    end
=end
  end

  # GET /selector_votes/1/edit
  def edit
    raise NotImplementedError

=begin
    @selector_vote = SelectorVote.find(params[:id])
=end
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

  # DELETE /selector_votes/1
  # DELETE /selector_votes/1.xml
  def destroy
    raise NotImplementedError

=begin
    @selector_vote = SelectorVote.find(params[:id])
    @selector_vote.destroy

    respond_to do |format|
      format.html { redirect_to(selector_votes_url) }
      format.xml  { head :ok }
    end
=end
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
