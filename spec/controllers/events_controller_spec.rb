require File.dirname(__FILE__) + '/../spec_helper'

describe EventsController, "when displaying events" do
  integrate_views
  fixtures :all

  context "index" do
    it "should display error if there's no current event" do
      Event.should_receive(:current).and_return(nil)
      get :index

      response.should be_success
      flash.has_key?(:failure).should be_true
    end

    it "should redirect if there's a current event" do
      event = events(:open)
      Event.should_receive(:current).and_return(event)
      get :index

      response.should redirect_to(event_proposals_path(event))
    end
  end

  context "show" do
    context "non-existent event" do
      before do
        get :show, :id => -1
      end

      it "should display error" do
        flash.has_key?(:failure).should be_true
      end

      it "should redirect to current event" do
        response.should redirect_to(event_path(events(:open)))
      end
    end

    context "extant event" do
      before do
        @event = events(:closed)
        get :show, :id => @event.slug
      end

      it "should display event" do
        response.should redirect_to(event_proposals_path(@event))
      end
    end
  end
end

