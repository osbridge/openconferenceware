require 'spec_helper'

describe "session_types/new.html.erb" do
  include SessionTypesHelper
  
  before(:each) do
    @session_type = stub_model(SessionType).as_new_record
    assign(:session_type, @session_type)

    @event = stub_current_event!
  end

  it "should render new form" do
    render
    
    rendered.should have_selector("form[action='#{session_types_path}'][method=post]") do |node|
      node.should have_selector("input#session_type_title[name='session_type[title]']")
      node.should have_selector("textarea#session_type_description[name='session_type[description]']")
      node.should have_selector("input#session_type_duration[name='session_type[duration]']")
    end
  end
end


