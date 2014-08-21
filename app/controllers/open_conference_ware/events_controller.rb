module OpenConferenceWare
  class EventsController < ApplicationController
    include BreadcrumbsMixin
    add_breadcrumb "Events", "/events"

    before_filter :assert_current_event_or_redirect
    before_filter :normalize_event_path_or_redirect
    before_filter :assert_proposal_status_published, only: :speakers
    before_filter :require_admin, only: [:selector_votes]

    def index
      @events = Event.order("deadline asc")

      respond_to do |format|
        format.html
        format.json { render json: @events }
        format.xml  { render xml:  @events }
      end
    end

    def show
      respond_to do |format|
        format.html { redirect_to event_proposals_path(@event) }
        format.json { render json: @event }
        format.xml  { render xml:  @event }
      end
    end

    def speakers
      assign_prefetched_hashes

      respond_to do |format|
        format.html
        format.json { render json: @speakers }
        format.xml  { render xml:  @speakers }
        format.csv  { render csv:  @speakers, style: admin? ? :full : :public }
      end
    end
  end
end
