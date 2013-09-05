require 'spec_helper'

describe "/tracks/show.html.erb" do
  include TracksHelper
  before(:each) do
    @event = stub_current_event!(:controller => template)
    assigns[:track] = @track = stub_model(Track,
      :title => "value for title",
      :event_id => 1,
      :description => "value for description"
    )

    template.stub(:schedule_visible?).and_return(true)
  end

  it "should render attributes in <p>" do
    render "/tracks/show.html.erb"
    response.should have_text(/value for description/)
  end
end

