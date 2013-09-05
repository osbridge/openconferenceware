require 'spec_helper'

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

  describe "when finding first admin user" do
    it "should find an admin user" do
      user = mock_model(User, :admin => true)
      User.should_receive(:find).and_return(user)

      result = User.find_first_admin
      result.should be_a_kind_of(User)
      result.admin.should be_true
    end

    it "should find nothing if there isn't an admin user" do
      User.should_receive(:find).and_return(nil)

      User.find_first_admin.should be_nil
    end
  end

  describe "when finding first non-admin user" do
    it "should find a non-admin user" do
      user = mock_model(User, :admin => false)
      User.should_receive(:find).and_return(user)

      result = User.find_first_non_admin
      result.should be_a_kind_of(User)
      result.admin.should be_false
    end

    it "should find nothing if there isn't a non-admin user" do
      User.should_receive(:find).and_return(nil)

      User.find_first_non_admin.should be_nil
    end
  end

  describe "remember_token" do
    before do
      @user1 = User.create_from_openid!('http://foo', {})
      @user1.remember_me

      @user2 = User.create_from_openid!('http://bar', {})
      @user2.remember_me
    end

    it "should have a salt" do
      @user1.salt.should_not be_blank
      @user2.salt.should_not be_blank
    end

    it "should have a unique salt" do
      @user1.salt.should_not == @user2.salt
    end

    it "should have a remember token" do
      @user1.remember_token.should_not be_blank
      @user2.remember_token.should_not be_blank
    end

    it "should have a unique remember token" do
      @user1.remember_token.should_not == @user2.remember_token
    end
  end

  describe "when creating a passworded account" do
    before do
      @password = 'mysecretpassword'
      @user = User.new(:email => 'foo@bar.com', :password => @password, :password_confirmation => @password)
      @user.login = 'foo'
      @user.save!
    end

    it "should exist" do
      @user.id.should_not be_blank
    end

    it "should have an crypted password" do
      @user.crypted_password.should_not be_blank
    end

    it "should have a salt" do
      @user.salt.should_not be_blank
    end

    it "should authenticate with a password" do
      @user.authenticated?(@password).should be_true
    end
  end
end
