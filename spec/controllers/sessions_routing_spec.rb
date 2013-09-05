require 'spec_helper'

describe ProposalsController do
  describe "route generation" do

    it "should map { :controller => 'proposals', :action => 'sessions_index' } to /sessions" do
      route_for(:controller => "proposals", :action => "sessions_index").should == "/sessions"
    end
  
  end

  describe "route recognition" do

    it "should generate params { :controller => 'proposals', action => 'sessions_index' } from GET /sessions" do
      params_from(:get, "/sessions").should == {:controller => "proposals", :action => "sessions_index"}
    end
      
  end
end
