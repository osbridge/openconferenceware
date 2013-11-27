require 'spec_helper'

describe User do
  describe "get" do
    before(:each) do
      @user = stub_model(User)
    end

    it "should return a given user instance" do
      User.get(@user).should == @user
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
      mock_model(User, :admin => true)
      result = User.find_first_admin
      result.should be_a_kind_of(User)
      result.admin.should be_true
    end

    it "should find nothing if there isn't an admin user" do
      User.destroy_all
      User.find_first_admin.should be_nil
    end

  end

  describe "when finding first non-admin user" do

    it "should find a non-admin user" do
      mock_model(User, :admin => false)
      result = User.find_first_non_admin
      result.should be_a_kind_of(User)
      result.admin.should be_false
    end

    it "should find nothing if there isn't a non-admin user" do
      User.destroy_all
      User.find_first_non_admin.should be_nil
    end

  end

  context "created from an authentication" do
    let(:authentication) { Factory.create(:authentication) }
    subject(:user) { User.create_from_authentication(authentication) }

    it { expect(user).to be_valid }
    it { expect(user).to be_persisted }
    it { expect(user.fullname).to eq authentication.name }
    it { expect(user.biography).to eq authentication.info["description"] }
    it { expect(user.website).to eq authentication.info["urls"]["wikipedia"] }
    it { expect(user.authentications).to include(authentication) }
  end
end
