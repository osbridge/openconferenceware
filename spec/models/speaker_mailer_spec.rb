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
  CHARSET = 'utf-8'

  it "should not send email if speaker_mailer is not configured" do
    SpeakerMailer.stub!(:configured? => false)

    lambda { SpeakerMailer.deliver_speaker_email('subject', 'text', 'quentin@example.com') }.should raise_error(ArgumentError)
  end

  it "should send email if speaker_mailer is configured" do
    stub_speaker_mailer_secrets

    lambda { SpeakerMailer.deliver_speaker_email('subject', 'congratulations text', 'quentin@example.com') }.should change(ActionMailer::Base.deliveries, :size).by(1)

    email = ActionMailer::Base.deliveries.last
    email.to.should == ['quentin@example.com']
    email.subject.should == 'subject'
    email.body.should == "congratulations text"
  end
end
