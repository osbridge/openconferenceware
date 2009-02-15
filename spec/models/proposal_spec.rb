require File.dirname(__FILE__) + '/../spec_helper'

describe Proposal do
  fixtures :all

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
      website = "http://foo.bar/"
      Proposal.new(:website => website).website.should == website
    end

    it "should accept ftp" do
      website = "ftp://foo.bar/"
      Proposal.new(:website => website).website.should == website
    end

    it "should prepend http" do
      Proposal.new(:website => "foo.com").website.should == "http://foo.com/"
    end

    it "should clear invalid websites" do
      # TODO Should this throw an exception or invalidate object instead?
      Proposal.new(:website => "qwerqew...qwerq.ewr///qwer").website.should be_nil
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

  context "when getting profile" do
    before(:each) do
      @proposal = proposals(:quentin_widgets)
    end

    it "should return false if multiple_presenters is enabled" do
      SETTINGS.stub!(:have_multiple_presenters).and_return(true)
      @proposal.profile.should be_false
    end

    it "should return the user if user_profiles is enabled" do
      SETTINGS.stub!(:have_multiple_presenters).and_return(false)
      SETTINGS.stub!(:have_user_profiles).and_return(true)
      @proposal.profile.should == @proposal.user
    end

    it "should return itself if multiple_presenters and user_profiles are disabled" do
      SETTINGS.stub!(:have_multiple_presenters).and_return(false)
      SETTINGS.stub!(:have_user_profiles).and_return(false)
      @proposal.profile.should == @proposal
    end

  end
end
