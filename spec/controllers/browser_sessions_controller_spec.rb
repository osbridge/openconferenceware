require 'spec_helper'

describe BrowserSessionsController do
  fixtures :all

  describe "destroy" do
    it "should redirect to an event's sessions if on an event with published statuses" do
      event = stub_current_event!
      event.stub!(:proposal_status_published? => true)
      login_as :quentin

      delete :destroy

      response.should redirect_to(event_sessions_path(event))
    end

    it "should redirect to an event's proposals if on an event without published statues" do
      event = stub_current_event!
      event.stub!(:proposal_status_published? => false)
      login_as :quentin

      delete :destroy

      response.should redirect_to(event_proposals_path(event))
    end

    it "should redirect to default proposals path if not on an event" do
      Event.stub!(:current => nil)
      login_as :quentin

      delete :destroy

      response.should redirect_to(proposals_path)
    end
  end
end
