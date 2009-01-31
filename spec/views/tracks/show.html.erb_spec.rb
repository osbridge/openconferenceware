require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tracks/show.html.erb" do
  include TracksHelper
  before(:each) do
    assigns[:event] = @event = stub_model(Event,
      :id => 1,
      :title => "Event 1"
    )
    assigns[:track] = @track = stub_model(Track,
      :title => "value for title",
      :event_id => 1,
      :description => "value for description"
    )
  end

  it "should render attributes in <p>" do
    render "/tracks/show.html.erb"
    response.should have_text(/value for description/)
  end
end

