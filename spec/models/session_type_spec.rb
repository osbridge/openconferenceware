require 'spec_helper'

describe SessionType do
  fixtures :all

  it "should sort alphabetically by title" do
    things = [ build(:session_type, :title => 'I love cats'),
               build(:session_type, :title => 'A really big dog'),
               nil ]
    sorted_things = things.sort
    sorted_things[0].should be_nil
    sorted_things[1].title.should == 'A really big dog'
    sorted_things[2].title.should == 'I love cats'
  end
end
