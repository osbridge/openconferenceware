require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  describe "get" do
    before(:each) do
      @user = stub_model(User)
    end

    it "should return a given user instance" do
      User.get(@user).should == @user
    end

    it "should return a user instance for the given logic symbol" do
      User.should_receive(:find_by_login).with("mykey").and_return(@user)
      User.get(:mykey).should == @user
    end

    it "should return a user instance for the given logic string" do
      User.should_receive(:find_by_login).with("mykey").and_return(@user)
      User.get("mykey").should == @user
    end

    it "should return a user instance for the given id" do
      User.should_receive(:find).with(42).and_return(@user)
      User.get(42).should == @user
    end

    it "should fail when given a nil" do
      lambda { User.get(nil) }.should raise_error(TypeError)
    end
  end
end
