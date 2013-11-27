require 'spec_helper'

describe Authentication do
  describe "finding or creating from an auth hash" do
    describe "when an an existing Authentication does not exist" do
      before do
        @auth_hash = OmniAuth::AuthHash.new(
          'provider' => 'test_provider',
          'uid' => Time.now.to_i.to_s,
          'info' => {
            'name' => 'Boris',
            'email' => 'boris@example.com'
          }
        )

        @new_auth = Authentication.find_and_update_or_create_from_auth_hash(@auth_hash)
      end

      it "should create new Authentications" do
        @new_auth.should_not be_new_record
      end

      it "should set base attributes from the auth hash" do
        @new_auth.provider.should == @auth_hash['provider']
        @new_auth.uid.should      == @auth_hash['uid']
      end

      it "should set name and email from the info hash" do
        @new_auth.name.should  == @auth_hash['info']['name']
        @new_auth.email.should == @auth_hash['info']['email']
      end

      it "should stash the info hash" do
        @new_auth.info.should == @auth_hash['info']
      end
    end

    describe "when an existing Authentication record exists" do
      before do
        @existing = Factory.create(:authentication)
        @auth_hash = OmniAuth::AuthHash.new(
          'provider' => @existing.provider,
          'uid' => @existing.uid,
          'info' => {
            'name' => 'Beth',
            'email' => 'beth@example.com'
          }
        )
        @found = Authentication.find_and_update_or_create_from_auth_hash(@auth_hash)
      end

      it "should find the existing record" do
        @found.should == @existing
      end

      it "should update the record's name and email from the auth hash" do
        @found.name.should  == @auth_hash['info']['name']
        @found.email.should == @auth_hash['info']['email']
      end

      it "should update the stashed copy of the info hash" do
        @found.info.should == @auth_hash['info']
      end
    end

  end
end
