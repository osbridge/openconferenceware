class SelectorVotesController < ApplicationController
  before_filter :require_selector

  # ROUTE: /events/:event_id/selector_votes
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
        when 'track'
          proposals.sort_by { |proposal| proposal.track_title }
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

  # ROUTE: /proposals/:proposal_id/selector_vote
  def create
    @selector_vote = SelectorVote.find_or_initialize_by_user_id_and_proposal_id(current_user.id, params[:proposal_id].to_i)
    @selector_vote.attributes = {
      :rating  => params[:selector_vote].ergo[:rating].to_i,
      :comment => params[:selector_vote].ergo[:comment]
    }

    respond_to do |format|
      if @selector_vote.save
        format.html {
          if next_proposal = @selector_vote.proposal.next_proposal
            redirect_to(next_proposal)
          else
            flash[:success] = "You've voted on the last proposal!"
            redirect_to(@selector_vote.proposal.event)
          end
        }
        format.xml  { render :xml => @selector_vote, :status => :ok }
      else
        flash[:failure] = @selector_vote.errors.full_messages.map {|o| "#{o}."}.join(" ")
        format.html { redirect_to(@selector_vote.proposal) }
        format.xml  { render :xml => @selector_vote.errors, :status => :unprocessable_entity }
      end
    end
  end
end
