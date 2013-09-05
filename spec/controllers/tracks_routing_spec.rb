require 'spec_helper'

describe TracksController do
  it "should test nested routes actually being used" # TODO
=begin
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "tracks", :action => "index").should == "/tracks"
    end
  
    it "should map #new" do
      route_for(:controller => "tracks", :action => "new").should == "/tracks/new"
    end
  
    it "should map #show" do
      route_for(:controller => "tracks", :action => "show", :id => 1).should == "/tracks/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "tracks", :action => "edit", :id => 1).should == "/tracks/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "tracks", :action => "update", :id => 1).should == "/tracks/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "tracks", :action => "destroy", :id => 1).should == "/tracks/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/tracks").should == {:controller => "tracks", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/tracks/new").should == {:controller => "tracks", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/tracks").should == {:controller => "tracks", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/tracks/1").should == {:controller => "tracks", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/tracks/1/edit").should == {:controller => "tracks", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/tracks/1").should == {:controller => "tracks", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/tracks/1").should == {:controller => "tracks", :action => "destroy", :id => "1"}
    end
  end
=end
end
