require 'spec_helper'

describe ProposalsController do
  describe "route recognition" do

    it "should generate params { controller: 'proposals', action => 'sessions_index' } from GET /sessions" do
      {get: "/sessions"}.should route_to(controller: "proposals", action: "sessions_index")
    end

  end
end
