require 'spec_helper'

  fixtures :users, :events
describe "open_conference_ware/users/index.html.erb" do

  before do
    stub_settings_accessors_on(view)
  end

  it "should not include admin column by default" do
    assign(:users, [users(:aaron), users(:quentin)])
    render

    rendered.should_not have_selector(".admin", text: "admin")
  end

  it "should include admin column when admin is logged in" do
    view.stub(:admin?).and_return(true)
    assign(:users, [users(:aaron), users(:quentin)])
    render

    rendered.should have_selector(".admin", text: "admin")
  end
end
