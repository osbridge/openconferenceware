require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tracks/new.html.erb" do
  include TracksHelper
  
  before(:each) do
    assigns[:track] = stub_model(Track,
      :new_record? => true,
      :title => "value for title",
      :event_id => 1
    )
  end

  it "should render new form" do
    render "/tracks/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", tracks_path) do
      with_tag("input#track_title[name=?]", "track[title]")
      with_tag("input#track_event_id[name=?]", "track[event_id]")
    end
  end
end


