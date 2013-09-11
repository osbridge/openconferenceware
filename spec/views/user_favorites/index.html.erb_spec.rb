require 'spec_helper'

describe "user_favorites/index.html.erb" do
  include UserFavoritesHelper
  fixtures :all

  before(:each) do
    stub_settings_accessors_on(view)

    @proposals = proposals(:couchdb_session, :bigtable_session)
    @user = users(:quentin)
    #@user.stub(:favorites => @proposals)
    @event = stub_current_event!(:controller => view)
    @event.stub(:proposal_status_published? => false)
    @event.stub(:schedule_visible? => false)

    assign(:user, @user)
    assign(:user_favorites, @proposals)
  end

  it "renders a list of user_favorites" do
    render

    rendered.should have_selector(".proposal_row", :count => 2)
    rendered.should have_selector("#proposal_row_#{@proposals[0].id}")
    rendered.should have_selector("#proposal_row_#{@proposals[1].id}")
  end
end

