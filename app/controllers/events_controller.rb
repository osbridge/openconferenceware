class EventsController < ApplicationController
  include BreadcrumbsMixin
  add_breadcrumb "Events", "/events"

  before_filter :assert_current_event_or_redirect
  before_filter :normalize_event_path_or_redirect
  before_filter :assert_proposal_status_published, :only => :speakers

  def index
    @events = Event.find(:all, :order => "deadline asc")
  end

  def show
    flash.keep
    redirect_to event_proposals_path(@event)
  end

  def speakers
    assign_prefetched_hashes
  end
end
