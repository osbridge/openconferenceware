require 'spec_helper'

describe "users/index.html.erb" do
  fixtures :users, :events

  it "should not include admin column by default" do
    pending "FIXME: Hangs the test suite when run as a whole"

    assign(:users, [users(:aaron), users(:quentin)])
    render

    rendered.should_not have_selector(".admin", :content => "admin")
  end

  it "should include admin column when admin is logged in" do
    pending "FIXME: Hangs the test suite when run as a whole"

    login_as(:aaron)
    assign(:users, [users(:aaron), users(:quentin)])
    render

    rendered.should have_selector(".admin", :content => "admin")
  end
end
