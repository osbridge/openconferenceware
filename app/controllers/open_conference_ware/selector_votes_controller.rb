module OpenConferenceWare
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
          proposals = @event.proposals.includes(:selector_votes, :comments, :users, :user_favorites)
          case params[:order]
          when 'title'
            proposals.sort_by { |proposal| [ proposal.title.downcase, proposal.id ] }
          when 'vote_points'
            proposals.sort_by { |proposal| [ 0 - proposal.selector_vote_points, 0 - proposal.user_favorites.size,  proposal.id ] }
          when 'votes_count'
            proposals.sort_by { |proposal| [ 0 - proposal.selector_votes.size,  0 - proposal.user_favorites.size,  proposal.id ] }
          when 'favorites_count'
            proposals.sort_by { |proposal| [ 0 - proposal.user_favorites.size,  0 - proposal.selector_vote_points, proposal.id ] }
          when 'track'
            proposals.sort_by { |proposal| [ proposal.track_title, proposal.id ] }
          when 'id', '', nil
            proposals.sort_by { |proposal| [ proposal.created_at, proposal.id ] }
          else # includes 'id'
            flash[:failure] = "Unknown order: #{h(params[:order])}"
            proposals.sort_by { |proposal| [ proposal.created_at, proposal.id ] }
          end
        end

      respond_to do |format|
        format.html
        format.csv { render csv: @proposals, style: :selector_votes }
      end
    end

    # ROUTE: /proposals/:proposal_id/selector_vote
    def create
      @selector_vote = SelectorVote.find_or_initialize_by(user_id: current_user.id, proposal_id: params[:proposal_id].to_i)
      @selector_vote.assign_attributes(selector_vote_params)

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
          format.xml  { render xml: @selector_vote, status: :ok }
        else
          flash[:failure] = @selector_vote.errors.full_messages.map {|o| "#{o}."}.join(" ")
          format.html { redirect_to(@selector_vote.proposal) }
          format.xml  { render xml: @selector_vote.errors, status: :unprocessable_entity }
        end
      end
    end

    private

      def selector_vote_params
        params.require(:selector_vote).permit(:rating, :comment) if selector?
      end
  end
end
