require 'spec_helper'

describe BrowserSessionsController do
  describe "route recognition" do

    it "should generate params { :controller => 'browser_sessions', action => 'index' } from GET /browser_sessions" do
      {:get => "/browser_sessions"}.should route_to({:controller => "browser_sessions", :action => "index"})
    end
    
    it "should generate params { :controller => 'browser_sessions', action => 'admin' } from GET /admin" do
      {:get => "/admin"}.should route_to({:controller => "browser_sessions", :action => "admin"})
    end
    
    it "should generate params { :controller => 'browser_sessions', action => 'logout' } from GET /logout" do
      {:get => "/logout"}.should route_to({:controller => "browser_sessions", :action => "destroy"})
    end
    
    it "should generate params { :controller => 'browser_sessions', action => 'new' } from GET /login" do
      {:get => "/login"}.should route_to({:controller => "browser_sessions", :action => "new"})
    end
    
    it "should generate params { :controller => 'browser_sessions', action => 'create' } from GET /browser_session" do
      {:get => "/browser_session"}.should route_to({:controller => "browser_sessions", :action => "create"})
    end
      
  end
end
