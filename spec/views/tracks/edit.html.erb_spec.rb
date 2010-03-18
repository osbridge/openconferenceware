require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tracks/edit.html.erb" do
  include TracksHelper
  
  before(:each) do
    @event = stub_current_event!

    assigns[:track] = @track = stub_model(Track,
      :new_record? => false,
      :title => "value for title",
      :event_id => @event.id
    )
  end

  it "should render edit form" do
    render "/tracks/edit.html.erb"
    
    response.should have_selector("form[action=#{track_path(@track)}][method=post]") do
      with_selector('input#track_title[name=?]', :content => "track[title]")
      with_selector('textarea#track_description[name=?]', :content => "track[description]")
    end
  end
end


