class EventsController < ApplicationController
  include BreadcrumbsMixin
  add_breadcrumb "Events", "/events"

  before_filter :assert_current_event_or_redirect
  before_filter :normalize_event_path_or_redirect

  def index
    @events = Event.find(:all, :order => "deadline asc")
  end

  def show
    flash.keep
    redirect_to event_proposals_path(@event)
  end
  
  def speakers
    @speakers = @event.speakers.scoped({:order => 'lower(last_name), lower(first_name)'})
  end
end
