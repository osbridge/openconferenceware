require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/session_types/show.html.erb" do
  include SessionTypesHelper
  before(:each) do
    assigns[:session_type] = @session_type = stub_model(SessionType)
  end

  it "should render attributes in <p>" do
    render "/session_types/show.html.erb"
  end
end

