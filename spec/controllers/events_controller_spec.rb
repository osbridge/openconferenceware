require File.dirname(__FILE__) + '/../spec_helper'

describe EventsController, "when displaying events" do
  integrate_views
  fixtures :all

  describe "index" do
    it "should display error if there's no current event" do
      Event.should_receive(:current).any_number_of_times.and_return(nil)
      get :index

      response.should be_success
      flash.has_key?(:failure).should be_true
    end

    it "should display a list of events" do
      get :index

      response.should be_success
      assigns[:events].should_not be_blank
    end
  end

  describe "show" do
    describe "non-existent event" do
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

    describe "extant event" do
      before do
        @event = events(:closed)
        get :show, :id => @event.slug
      end

      it "should display event" do
        response.should redirect_to(event_proposals_path(@event))
      end
    end
  end

  describe "speakers" do
    before do
      @event = events(:open)
      stub_current_event!(:event => @event)
    end

    describe "before proposals statuses published" do
      before do
        @event.stub!(:proposal_status_published? => false)

        get :speakers, :event_id => @event.to_param
      end

      it "should redirect to event's proposals" do
        response.should redirect_to(event_proposals_path(@event))
      end

      it "should display a flash error" do
        flash[:failure].should_not be_blank
      end

    end

    describe "after proposals statuses published" do
      before do
        @event.stub!(:proposal_status_published? => true)
        @event.stub!(:schedule_published? => true)

        get :speakers, :event_id => @event.to_param
      end

      it "should get a speaker's page" do
        response.should be_success
      end

      it "should see speakers" do
        response.should have_selector(".fn", :content => users(:quentin).fullname)
      end

      it "should see sessions" do
        response.should have_selector(".summary", :content => proposals(:postgresql_session).title)
      end

      it "should not see non-confirmed proposals" do
        response.should_not have_selector(".summary", :content => proposals(:clio_chupacabras).title)
      end
    end

  end
end

