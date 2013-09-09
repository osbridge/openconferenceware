require 'spec_helper'

describe "tracks/new.html.erb" do
  include TracksHelper
  
  before(:each) do
    @event = stub_current_event!

    @track = stub_model(Track,
      :title => "value for title",
      :event_id => 1
    ).as_new_record
    assign(:track, @track)
  end

  it "should render new form" do
    render
    
    rendered.should have_selector("form[action='#{tracks_path}'][method=post]") do |node|
      node.should have_selector("input#track_title[name='track[title]']")
      node.should have_selector("textarea#track_description[name='track[description]']")
    end
  end
end


