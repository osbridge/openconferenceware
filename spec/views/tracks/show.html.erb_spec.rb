require 'spec_helper'

describe "tracks/show.html.erb" do
  include TracksHelper
  before(:each) do
    @event = stub_current_event!(:controller => view)
    @track = stub_model(Track,
      :title => "value for title",
      :event_id => 1,
      :description => "value for description"
    )
    assign(:track, @track)

    view.stub(:schedule_visible?).and_return(true)
    view.stub(:admin?).and_return(false)
  end

  it "should render attributes in <p>" do
    render
    rendered.should have_text(/value for description/)
  end
end

