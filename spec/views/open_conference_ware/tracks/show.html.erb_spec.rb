require 'spec_helper'

describe "open_conference_ware/tracks/show.html.erb" do
  include OpenConferenceWare::TracksHelper
  before(:each) do
    stub_settings_accessors_on(view)
    @event = stub_current_event!(controller: view)
    @track = stub_model(Track,
      title: "value for title",
      event_id: 1,
      description: "value for description"
    )
    assign(:track, @track)

    view.stub(:schedule_visible?).and_return(true)
    view.stub(:admin?).and_return(false)
  end

  it "should render attributes in <p>" do
    render
    rendered.should match(/value for description/)
  end
end
