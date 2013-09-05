require 'spec_helper'

describe NormalizeUrlMixin do
  describe "normalize_url!" do
    it "should preserve valid URLs as-is" do
      NormalizeUrlMixin.normalize_url!('http://foo.bar/').should == 'http://foo.bar/'
    end

    it "should append trailing slash to URLs" do
      NormalizeUrlMixin.normalize_url!('http://foo.bar').should == 'http://foo.bar/'
    end

    it "should preserve valid URLs with paths as-is" do
      NormalizeUrlMixin.normalize_url!('http://foo.bar/baz').should == 'http://foo.bar/baz'
    end

    it "should add http schema to pure hostnames" do
      NormalizeUrlMixin.normalize_url!('foo.bar').should == 'http://foo.bar/'
    end

    it "should add http schema to hostname/paths" do
      NormalizeUrlMixin.normalize_url!('foo.bar/baz').should == 'http://foo.bar/baz'
    end
  end

  describe "validation" do
    fixtures :users
    # TODO Mock an entire ActiveRecord model to isolate these behaviors, rather than relying on User
    before(:each) do
      @record = users(:aaron)
    end

    it "should handle nil" do
      @record.website = nil
      @record.should be_valid
      @record.website.should be_blank
    end

    it "should handle blank" do
      @record.website = ''
      @record.should be_valid
      @record.website.should be_blank
    end

    it "should handle valid" do
      @record.website = 'http://foo.bar/'
      @record.should be_valid
      @record.website.should == 'http://foo.bar/'
    end

    it "should handle unqualified" do
      @record.website = 'foo.bar'
      @record.should be_valid
      @record.website.should == 'http://foo.bar/'
    end

    it "should fail invalid" do
      @record.website = '<asdf>'
      @record.should_not be_valid
      @record.errors.on(:website).should == "is invalid"
    end
  end
end
