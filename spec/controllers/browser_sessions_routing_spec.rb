require 'spec_helper'

describe BrowserSessionsController do
  describe "route generation" do

    it "should map { :controller => 'browser_sessions', :action => 'index' } to /browser_sessions" do
      route_for(:controller => "browser_sessions", :action => "index").should == "/browser_sessions"
    end
    
    it "should map { :controller => 'browser_sessions', :action => 'admin' } to /admin" do
      route_for(:controller => "browser_sessions", :action => "admin").should == "/admin"
    end
    
    it "should map { :controller => 'browser_sessions', :action => 'destroy' } to /logout" do
      route_for(:controller => "browser_sessions", :action => "destroy").should == "/logout"
    end
    
    it "should map { :controller => 'browser_sessions', :action => 'new' } to /login" do
      route_for(:controller => "browser_sessions", :action => "new").should == "/login"
    end
  
  end

  describe "route recognition" do

    it "should generate params { :controller => 'browser_sessions', action => 'index' } from GET /browser_sessions" do
      params_from(:get, "/browser_sessions").should == {:controller => "browser_sessions", :action => "index"}
    end
    
    it "should generate params { :controller => 'browser_sessions', action => 'admin' } from GET /admin" do
      params_from(:get, "/admin").should == {:controller => "browser_sessions", :action => "admin"}
    end
    
    it "should generate params { :controller => 'browser_sessions', action => 'logout' } from GET /logout" do
      params_from(:get, "/logout").should == {:controller => "browser_sessions", :action => "destroy"}
    end
    
    it "should generate params { :controller => 'browser_sessions', action => 'new' } from GET /login" do
      params_from(:get, "/login").should == {:controller => "browser_sessions", :action => "new"}
    end
    
    it "should generate params { :controller => 'browser_sessions', action => 'create' } from GET /browser_session" do
      params_from(:get, "/browser_session").should == {:controller => "browser_sessions", :action => "create", :method => :get}
    end
      
  end
end