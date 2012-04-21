# Emailthing
module Emailthing

  MESSAGE_TYPE_HEADER = "x-emailthing-message-type"

  def perform_delivery_emailthing(message)
    api_key = self.class.emailthing_settings[:api_key]
    if api_key.nil? or api_key.empty?
      raise ApiKeyMissing.new("You must provide an api key. See http://emailthing.net/help/api_key_missing for more information")
    end
    set_message_type(message)
    Net::HTTP.post_form(URI.parse("http://catcher.emailthing.net/catcher/projects/#{api_key}/emails"),
        :email  => message.encoded
    )

  end

  def set_message_type(message)
    if message.header[MESSAGE_TYPE_HEADER].blank?
      message[MESSAGE_TYPE_HEADER] = "#{@mailer_name}##{@template}"
    end
  end

  def emailthing_message_type(message_type)
    headers MESSAGE_TYPE_HEADER=>message_type
  end

  def self.api_key=(val)
    ActionMailer::Base.emailthing_settings = {:api_key=>val}
  end

  class ApiKeyMissing < Exception; end

end
