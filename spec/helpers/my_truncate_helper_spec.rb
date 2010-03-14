require File.dirname(__FILE__) + '/../spec_helper'

describe MyTruncateHelper do
  it "should truncate a long string" do
    helper.my_truncate("a very long string", 10).should == "a very ..."
  end

  it "should not truncate a short string" do
    helper.my_truncate("foo").should == "foo"
  end

  it "should skip nil" do
    helper.my_truncate(nil).should == nil 
  end
end
