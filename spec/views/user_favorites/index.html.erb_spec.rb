require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/user_favorites/index.html.erb" do
  include UserFavoritesHelper

  before(:each) do
    # OMFG how many objects must a man stub
    @user = stub_model(User)
    @event = stub_current_event!(:controller => template)
    @event.stub!(:proposal_status_published? => false)
    @event.stub!(:schedule_visible? => false)
    @proposals = [
      stub_model(Proposal, :id => 23, :title => "A talk", :users => [@user], :event => @event),
      stub_model(Proposal, :id => 42, :title => "Another talk", :users => [@user], :event => @event),
    ]
    @container = mock(Array, :proposals => mock(Array, :all => @proposals), :id => 1)
    @user = assigns[:user] = stub_model(User, :favorites => @container)
    template.stub!(:schedule_visible? => false)
  end

  it "renders a list of user_favorites" do
    render "user_favorites/index.html.erb"

    response.should have_tag '.proposal_row', :count => 2
    response.should have_tag '#proposal_row_23'
    response.should have_tag '#proposal_row_42'
  end
end

