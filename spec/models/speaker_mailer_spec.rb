require 'spec_helper'

def stub_speaker_mailer_secrets
  SECRETS.stub!(:email => {
    'default_from_address' => 'test@example.com',
    'default_bcc_address' => 'me@example.com',
    'action_mailer' => {
      :delivery_method => :test
    }
  })
end

def deliver_email(proposal)
  SpeakerMailer.deliver_speaker_email('proposals_acceptance_email_subject', 'proposals_acceptance_email_text', proposal)
end

describe SpeakerMailer do
  fixtures :proposals, :tracks, :session_types, :users, :proposals_users, :snippets
  CHARSET = 'utf-8'

  before(:each) do
    stub_speaker_mailer_secrets
    @proposal = proposals(:quentin_widgets)
  end

  context "when sending email" do
    it "should raise error if speaker_mailer is not configured" do
      SpeakerMailer.stub(:configured?).and_return(false)
      lambda { deliver_email(@proposal) }.should raise_error(ArgumentError)
    end

    it "should send email if speaker_mailer is configured" do
      lambda { deliver_email(@proposal) }.should change(ActionMailer::Base.deliveries, :size).by(1)
      email = ActionMailer::Base.deliveries.last
      email.to.should == ['quentin@example.com']
      email.subject.should =~ /Your talk was accepted/
    end

    it "should BCC the default_bcc_address" do
      deliver_email(@proposal)
      email = ActionMailer::Base.deliveries.last
      email.bcc.should == ['me@example.com']
    end
  end

  context "when fetching speaker email content" do
    it "should contain the template text" do
      deliver_email(@proposal)
      email = ActionMailer::Base.deliveries.last
      email.body.should =~ /Congratulations/
    end

    it "should fill in email template variables" do
      deliver_email(@proposal)
      email = ActionMailer::Base.deliveries.last
      email.body.should =~ /proposals\/speaker_confirm/
      email.body.should =~ /proposals\/speaker_decline/
      email.body.should =~ /Quentin/
      email.body.should =~ /My favorite widgets./
      email.body.should =~ /Chemistry/
      email.body.should =~ /Beginner/
      email.body.should =~ /long/
      email.body.should =~ /\n/
      email.body.should_not =~ /<|>/
    end

    it "should not break if proposal start_time doesn't exist" do
      deliver_email(@proposal)
      email = ActionMailer::Base.deliveries.last
      email.body.should =~ /Unscheduled/
    end

    it "should fill in proposal start_time if start_time exists" do
      @scheduled_proposal = proposals(:postgresql_session)
      deliver_email(@scheduled_proposal)
      email = ActionMailer::Base.deliveries.last
      email.body.should =~ /June 17/
    end

    it "should raise error if email template not found" do
      lambda { SpeakerMailer.deliver_speaker_email('proposals_acceptance_email_subject', 'error_email', @proposal) }.should raise_error(ActiveRecord::RecordNotFound, /Can't find snippet: error_email/)
    end

    it "should raise error if subject template not found" do
      lambda { SpeakerMailer.deliver_speaker_email('error_subject', 'proposals_acceptance_email_text', @proposal) }.should raise_error(ActiveRecord::RecordNotFound, /Can't find snippet: error_subject/)
    end
  end

end
