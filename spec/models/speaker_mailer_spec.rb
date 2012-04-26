require File.dirname(__FILE__) + '/../spec_helper'

def stub_speaker_mailer_secrets
  SECRETS.stub!(:speaker_mailer => {
    'address' => 'myprovider.com',
    'port' => 587,
    'authentication' => 'plain',
    'enable_starttls_auto' => true,
    'user_name' => 'test',
    'password' => 'test',
  })
end

describe SpeakerMailer do
  fixtures :proposals, :snippets
  CHARSET = 'utf-8'

  before(:each) do
    @proposal = proposals(:quentin_widgets)
  end

  context "when sending email" do
    it "should not send email if speaker_mailer is not configured" do
      SpeakerMailer.stub!(:configured? => false)

      lambda { SpeakerMailer.deliver_speaker_email('acceptance_subject', 'acceptance_email', @proposal) }.should raise_error(ArgumentError)
    end

    it "should send email if speaker_mailer is configured" do
      stub_speaker_mailer_secrets

      lambda { SpeakerMailer.deliver_speaker_email('acceptance_subject', 'acceptance_email', @proposal) }.should change(ActionMailer::Base.deliveries, :size).by(1)

      email = ActionMailer::Base.deliveries.last
      email.to.should == ['quentin@example.com']
      email.subject.should =~ /Your talk was accepted/
      email.body.should =~ /Congratulations/
    end
  end

  context "when fetching speaker email content" do
    before(:each) do
      @proposal = proposals(:quentin_widgets)
    end

    it "should fill in email template" do
      stub_speaker_mailer_secrets

      lambda { SpeakerMailer.deliver_speaker_email('acceptance_subject', 'acceptance_email', @proposal) }.should change(ActionMailer::Base.deliveries, :size).by(1)

      email = ActionMailer::Base.deliveries.last
      email.body.should =~ /proposals\/speaker_confirm/
      email.body.should =~ /proposals\/speaker_decline/
      email.body.should =~ /Quentin/
      email.body.should =~ /My favorite widgets./
      email.body.should =~ /Chemistry/
      email.body.should =~ /Beginner/
      email.body.should =~ /Long/
      email.body.should =~ /\n/
      email.body.should_not =~ /<|>/
    end

    it "should raise error if email template not found" do
      lambda { SpeakerMailer.deliver_speaker_email('acceptance_subject', 'test_text', @proposal) }.should raise_error(ActiveRecord::RecordNotFound)
    end

    it "should raise error if subject template not found" do
      lambda { SpeakerMailer.deliver_speaker_email('test_subject', 'acceptance_email', @proposal) }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

end
