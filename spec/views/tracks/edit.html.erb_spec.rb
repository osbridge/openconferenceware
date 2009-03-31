require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tracks/edit.html.erb" do
  include TracksHelper
  
  before(:each) do
    @event = stub_model(Event,
      :id => 1,
      :title => "Event 1"
    )

    @controller.stub!(:get_current_event_and_assignment_status).and_return([@event, :assigned_to_current])
    assigns[:track] = @track = stub_model(Track,
      :new_record? => false,
      :title => "value for title",
      :event_id => @event.id
    )
  end

  it "should render edit form" do
    render "/tracks/edit.html.erb"
    
    response.should have_tag("form[action=#{track_path(@track)}][method=post]") do
      with_tag('input#track_title[name=?]', "track[title]")
      with_tag('textarea#track_description[name=?]', "track[description]")
    end
  end
end


