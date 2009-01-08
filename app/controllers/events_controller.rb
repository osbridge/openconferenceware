class EventsController < ApplicationController
  include BreadcrumbsMixin
  add_breadcrumb "Events", "/events"

  def index
    return if assign_current_event
  end

  def show
    return if assign_current_event
    redirect_to event_proposals_path(@event)
  end
end
