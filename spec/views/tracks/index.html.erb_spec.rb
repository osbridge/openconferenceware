require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tracks/index.html.erb" do
  include TracksHelper
  
  before(:each) do
    assigns[:event] = stub_model(Event,
      :id => 1,
      :title => "Event 1"
    )
    assigns[:tracks] = [
      stub_model(Track,
        :title => "value for title",
        :event_id => 1
      ),
      stub_model(Track,
        :title => "value for title",
        :event_id => 1
      )
    ]
  end

  it "should render list of tracks" do
    render "/tracks/index.html.erb"
    response.should have_tag("tr>td", "value for title".to_s, 2)
  end
end

