require File.dirname(__FILE__) + '/../spec_helper'

describe Proposal do
  fixtures :proposals, :events, :users

  context "when checking authorization for altering" do
    before(:each) do
      @proposal = proposals(:quentin_widgets)
    end

    it "should not allow anonymous" do
      @proposal.can_alter?(nil).should be_false
    end

    it "should not allow wrong mortal" do
      @proposal.can_alter?(users(:clio)).should be_false
    end

    it "should allow mortal owner" do
      @proposal.can_alter?(users(:quentin)).should be_true
    end

    it "should allow admin" do
      @proposal.can_alter?(users(:aaron)).should be_true
    end
  end

  context "when normalizing URLs" do
    it "should accept http" do
      url = "http://foo.bar/"
      Proposal.new(:url => url).url.should == url
    end

    it "should accept ftp" do
      url = "ftp://foo.bar/"
      Proposal.new(:url => url).url.should == url
    end

    it "should prepend http" do
      Proposal.new(:url => "foo.com").url.should == "http://foo.com/"
    end

    it "should clear invalid URLs" do
      # TODO Should this throw an exception or invalidate object instead?
      Proposal.new(:url => "qwerqew...qwerq.ewr///qwer").url.should be_nil
    end
  end

  context "when setting submitted_at date" do
    it "should set value on save" do
      proposal = proposals(:quentin_widgets)
      proposal.submitted_at = nil
      proposal.save!
      proposal.reload
      
      proposal.submitted_at.should_not be_nil
    end

    it "should set value to created_at date" do
      proposal = proposals(:quentin_widgets)
      proposal.submitted_at = nil
      proposal.save!
      proposal.reload
      
      proposal.submitted_at.should == proposal.created_at
    end
  end

  context "when getting comments" do
    before(:each) do
      @proposal = proposals(:quentin_widgets)
    end

    it "should return nothing if no comments" do
      @proposal.comments_text.blank?.should be_true
    end

    it "should return one comment" do
      comments = [
        mock(Comment, :email => "bubba@smith.com", :message => "Hi"),
      ]
      @proposal.should_receive(:comments).and_return(comments)

      @proposal.comments_text.should == "bubba@smith.com: Hi"
    end

    it "should return multiple comments" do
      comments = [
        mock(Comment, :email => "bubba@smith.com", :message => "Hi"),
        mock(Comment, :email => "billy.sue@smith.com", :message => "Yo"),
      ]
      @proposal.should_receive(:comments).and_return(comments)

      @proposal.comments_text.should ==
        "bubba@smith.com: Hi\nbilly.sue@smith.com: Yo"
    end
  end
end
