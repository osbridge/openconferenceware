require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/session_types/index.html.erb" do
  include SessionTypesHelper
  
  before(:each) do
    assigns[:session_types] = [
      stub_model(SessionType),
      stub_model(SessionType)
    ]
  end

  it "should render list of session_types" do
    render "/session_types/index.html.erb"
  end
end

