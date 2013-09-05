require 'spec_helper'

describe Track do
  fixtures :all

  before(:each) do
    @valid_attributes = {
      :title => "value for title",
      :description => "value for description",
      :excerpt => "value for excerpt",
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

  it "should sort alphabetically by title" do
    tracks = [ Track.new(:title => 'Blues'),
               Track.new(:title => 'Punk'),
               Track.new(:title => 'Folk'),
               nil ]

    sorted_tracks = tracks.sort
    sorted_tracks[0].should be_nil
    sorted_tracks[1].title.should == 'Blues'
    sorted_tracks[2].title.should == 'Folk'
    sorted_tracks[3].title.should == 'Punk'
  end
end
