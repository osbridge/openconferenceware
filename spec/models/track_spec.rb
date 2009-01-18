require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Track do
  fixtures :events

  before(:each) do
    @valid_attributes = {
      :title => "value for title",
      :description => "value for description",
      :color => "#00CC00",
      :event_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    Track.create!(@valid_attributes)
  end

  it "should not be valid without an event" do
    Track.new(:title => "My title").should_not be_valid
  end
end
