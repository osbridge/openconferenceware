require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tracks/edit.html.erb" do
  include TracksHelper
  
  before(:each) do
    assigns[:track] = @track = stub_model(Track,
      :new_record? => false,
      :title => "value for title",
      :event_id => 1
    )
  end

  it "should render edit form" do
    render "/tracks/edit.html.erb"
    
    response.should have_tag("form[action=#{track_path(@track)}][method=post]") do
      with_tag('input#track_title[name=?]', "track[title]")
      with_tag('input#track_event_id[name=?]', "track[event_id]")
    end
  end
end


