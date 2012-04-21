require "spec_helper"
describe Emailthing do
  describe "Setup" do

    it "should load the delivery method" do
      ActionMailer::Base.instance_methods.should include("perform_delivery_emailthing")
    end

    it "should allow you to fetch settings for emailthing" do
      ActionMailer::Base.emailthing_settings.should == {:api_key => nil}
    end

  end

  describe "execution" do
    before(:each) do
      #actionmailer makes new private
      #their initialize does nothing and doesn't call super, so this should be okay
      @mailer_instance = ActionMailer::Base.allocate
      Net::HTTP.stub!(:post_form)
      ActionMailer::Base.emailthing_settings = {:api_key=>"my_api_key"}
    end
    it "should raise an error if no api key is set" do
      ActionMailer::Base.emailthing_settings = {:api_key=>nil}
      lambda {
        @mailer_instance.perform_delivery_emailthing(TMail::Mail.new)
      }.should raise_error(Emailthing::ApiKeyMissing)

    end

    it "should post the form" do
      Net::HTTP.should_receive(:post_form).with(URI.parse("http://emailthing.net/projects/my_api_key/sent_emails"),an_instance_of(Hash))
      @mailer_instance.perform_delivery_emailthing(TMail::Mail.new)
    end

    it "should allow you to configure the environment by calling the Emailthing.api_key= method" do
      ActionMailer::Base.emailthing_settings = {:api_key=>nil}
      Emailthing.api_key = "mike test"
      ActionMailer::Base.emailthing_settings.should == {:api_key=>"mike test"}

    end
  end

  class TestMailer < ActionMailer::Base
    def test_email_no_message_type
      recipients "mike@example.com"
      subject "This is a test"
      from "no-reply@example.com"
    end

    def test_email_custom_message_type
      recipients "mike@example.com"
      subject "This is a test"
      from "no-reply@example.com"
      emailthing_message_type "custom"
    end

    #kill template handling
    def render(*args)
      ""
    end

    # give access to the tmail handling
    # hiding behind a private new is really painful
    def self.instance=(val)
      @instance = val
    end

    def self.instance
      @instance
    end

    def message
      @message
    end

    def perform_delivery_emailthing(message)
      self.class.instance = self
      @message = message
      super
    end
  end

  describe "Mailer" do

    before(:each) do
      Net::HTTP.stub!(:post_form)
      ActionMailer::Base.delivery_method = :emailthing
      Emailthing.api_key = "miketest"
    end

    it "should set the custom header correctly" do
      TestMailer.deliver_test_email_custom_message_type
      tmail = TestMailer.instance.message
      tmail.header["x-emailthing-message-type"].to_s.should == "custom"
    end

    it "should default to the mailer name and templte" do
      TestMailer.deliver_test_email_no_message_type
      tmail = TestMailer.instance.message
      tmail.header["x-emailthing-message-type"].to_s.should == "test_mailer#test_email_no_message_type"
    end
  end
end