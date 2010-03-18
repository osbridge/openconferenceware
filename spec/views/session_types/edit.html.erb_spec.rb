require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/session_types/edit.html.erb" do
  include SessionTypesHelper
  
  before(:each) do
    @event = stub_current_event!
    assigns[:session_type] = @session_type = stub_model(SessionType,
      :new_record? => false
    )
  end

  it "should render edit form" do
    render "/session_types/edit.html.erb"
    
    response.should have_selector("form[action=#{session_type_path(@session_type)}][method=post]") do
    end
  end
end


