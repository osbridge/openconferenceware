require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tracks/index.html.erb" do
  include TracksHelper
  
  before(:each) do
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
    response.should have_tag("tr>td", 1.to_s, 2)
  end
end

