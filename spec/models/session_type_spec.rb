require 'spec_helper'

describe SessionType do
  fixtures :all

  it "should sort alphabetically by title" do
    things = [ SessionType.new(:title => 'I love cats'), 
               SessionType.new(:title => 'A really big dog'),
               nil ]
    sorted_things = things.sort
    sorted_things[0].should be_nil
    sorted_things[1].title.should == 'A really big dog'
    sorted_things[2].title.should == 'I love cats'
  end
end
