require File.dirname(__FILE__) + '/../../spec_helper'

describe "/users" do
  fixtures :users, :events

  it "should not include admin column by default" do
    assigns[:users] = [users(:aaron), users(:quentin)]
    render '/users/index'

    response.should_not have_selector(".admin", :content => "admin")
  end

  it "should include admin column when admin is logged in" do
    login_as(:aaron)
    assigns[:users] = [users(:aaron), users(:quentin)]
    render '/users/index'

    response.should have_selector(".admin", :content => "admin")
  end
end
