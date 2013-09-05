require 'spec_helper'

describe SessionTypesController do
  it "should test SessionTypesHelper routing"
=begin
  include SessionTypesHelper

  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "session_types", :action => "index").should == "/session_types"
    end
  
    it "should map #new" do
      route_for(:controller => "session_types", :action => "new").should == "/session_types/new"
    end
  
    it "should map #show" do
      route_for(:controller => "session_types", :action => "show", :id => 1).should == "/session_types/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "session_types", :action => "edit", :id => 1).should == "/session_types/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "session_types", :action => "update", :id => 1).should == "/session_types/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "session_types", :action => "destroy", :id => 1).should == "/session_types/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/session_types").should == {:controller => "session_types", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/session_types/new").should == {:controller => "session_types", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/session_types").should == {:controller => "session_types", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/session_types/1").should == {:controller => "session_types", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/session_types/1/edit").should == {:controller => "session_types", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/session_types/1").should == {:controller => "session_types", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/session_types/1").should == {:controller => "session_types", :action => "destroy", :id => "1"}
    end
  end
=end
end
