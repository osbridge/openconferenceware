require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  describe "get" do
    before(:each) do
      @user = stub_model(User)
    end

    it "should return a given user instance" do
      User.get(@user).should == @user
    end

    it "should return a user instance for the given login symbol" do
      User.should_receive(:find_by_login).with("mykey").and_return(@user)
      User.get(:mykey).should == @user
    end

    it "should return a user instance for the given id string" do
      User.should_receive(:find).with(42).and_return(@user)
      User.get("42").should == @user
    end

    it "should return a user instance for the given id" do
      User.should_receive(:find).with(42).and_return(@user)
      User.get(42).should == @user
    end

    it "should fail when given a nil" do
      lambda { User.get(nil) }.should raise_error(TypeError)
    end
  end

  describe "blog links" do
    fixtures :users

    before(:each) do
      @user = users(:quentin)
    end

    it "should validate blog_url" do
      @user.blog_url = "http://foo.bar/"
      @user.should be_valid
    end

    it "should invalidate bad blog_url" do
      @user.blog_url = "omg://"
      @user.should_not be_valid
    end

    it "should return twitter url" do
      @user.twitter = "bubba"
      @user.twitter_url.should == "http://twitter.com/bubba"
    end

    it "should return nil if no twitter" do
      @user.twitter = nil
      @user.twitter_url.should be_blank
    end

    it "should return identica url" do
      @user.identica = "bubba"
      @user.identica_url.should == "http://identi.ca/bubba"
    end

    it "should return nil if no identica" do
      @user.identica = nil
      @user.identica_url.should be_blank
    end
  end
end
