require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tracks/new.html.erb" do
  include TracksHelper
  
  before(:each) do
    @event = stub_current_event!

    @track = stub_model(Track,
      :new_record? => true,
      :title => "value for title",
      :event_id => 1
    )
    assigns[:track] = @track
  end

  it "should render new form" do
    render "/tracks/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", tracks_path) do
      with_tag("input#track_title[name=?]", "track[title]")
      with_tag('textarea#track_description[name=?]', "track[description]")
    end
  end
end


