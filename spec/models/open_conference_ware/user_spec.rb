require 'spec_helper'

describe OpenConferenceWare::User do
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
    fixtures :open_conference_ware_users

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

  describe "move all associations from one user account to another" do
    fixtures :open_conference_ware_proposals
    fixtures :open_conference_ware_users

    before(:each) do
      @orig = users(:quentin)
      @dup = users(:quentin2)

      @dup.authentications << build(:authentication)
      UserFavorite.add(@dup.id, proposals(:postgresql_session).id)
      setup_selector_votes
    end

    def setup_selector_votes
      vote = proposals(:aaron_aardvarks).selector_votes.new(rating: 5, comment: "top choice")
      vote.user = @dup
      vote.save
    end

    def take_associations
      @orig.take_associations_from(@dup)
    end

    it "expects duplicate user to start with some associations" do
      expect(@dup.authentications.count).to eq 1
      expect(@dup.proposals.count).to eq 2
      expect(@dup.user_favorites.count).to eq 1
      expect(@dup.selector_votes.count).to eq 1
    end

    it "moves all authentications into original user" do
      expect { take_associations }.to change(@orig.authentications, :count).by(1)
    end

    it "moves all proposals into original user" do
      expect { take_associations }.to change(@orig.proposals, :count).by(2)
    end

    it "moves all user_favorites into original user" do
      expect { take_associations }.to change(@orig.user_favorites, :count).by(1)
    end

    it "moves all selector_votes into original user" do
      expect { take_associations }.to change(@orig.selector_votes, :count).by(1)
    end

    it "removes all associations from duplicate user" do
      take_associations
      @dup.reload
      expect(@dup.authentications.count).to eq 0
      expect(@dup.proposals.count).to eq 0
      expect(@dup.user_favorites.count).to eq 0
      expect(@dup.selector_votes.count).to eq 0
    end
  end

  context "created from an authentication" do
    let(:authentication) { build(:authentication) }
    subject(:user) { User.create_from_authentication(authentication) }

    it { expect(user).to be_valid }
    it { expect(user).to be_persisted }
    it { expect(user.fullname).to eq authentication.name }
    it { expect(user.biography).to eq authentication.info["description"] }
    it { expect(user.website).to eq authentication.info["urls"]["wikipedia"] }
    it { expect(user.authentications).to include(authentication) }
  end
end
