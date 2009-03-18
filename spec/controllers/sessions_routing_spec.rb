require File.dirname(__FILE__) + '/../spec_helper'

describe ProposalsController do
  describe "route generation" do

    it "should map { :controller => 'proposals', :action => 'confirmed' } to /sessions" do
      route_for(:controller => "proposals", :action => "confirmed").should == "/sessions"
    end
  
  end

  describe "route recognition" do

    it "should generate params { :controller => 'proposals', action => 'confirmed' } from GET /sessions" do
      params_from(:get, "/sessions").should == {:controller => "proposals", :action => "confirmed"}
    end
      
  end
end