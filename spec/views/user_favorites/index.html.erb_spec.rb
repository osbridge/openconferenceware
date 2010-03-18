require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/user_favorites/index.html.erb" do
  include UserFavoritesHelper
  fixtures :all

  before(:each) do
    @proposals = proposals(:couchdb_session, :bigtable_session)
    @user = users(:quentin)
    #@user.stub!(:favorites => @proposals)
    @event = stub_current_event!(:controller => template)
    @event.stub!(:proposal_status_published? => false)
    @event.stub!(:schedule_visible? => false)
    template.stub!(:schedule_visible? => false)

    assigns[:user] = @user
    assigns[:user_favorites] = @proposals
  end

  it "renders a list of user_favorites" do
    render "user_favorites/index.html.erb"

    response.should have_selector(".proposal_row", :count => 2)
    response.should have_selector("#proposal_row_#{@proposals[0].id}")
    response.should have_selector("#proposal_row_#{@proposals[1].id}")
  end
end

