require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/session_types/new.html.erb" do
  include SessionTypesHelper
  
  before(:each) do
    @session_type = stub_model(SessionType,
      :new_record? => true
    )
    assigns[:session_type] = @session_type

    @event = stub_current_event!
  end

  it "should render new form" do
    render "/session_types/new.html.erb"
    
    response.should have_selector("form[action=?][method=post]", session_types_path) do
    end
  end
end


