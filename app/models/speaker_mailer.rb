class SpeakerMailer < ActionMailer::Base

  def self.configured?
    return false unless SECRETS.speaker_mailer
    hostname = SECRETS.speaker_mailer['address']
    return(hostname && hostname != 'test')
  end

  def speaker_email(subject, body_text, emails)
    unless self.class.configured?
      raise ArgumentError, "Email settings for 'speaker_mailer' must be set in 'config/secrets.yml'"
    end
    recipients emails
    from       SECRETS.speaker_mailer['from'] || SECRETS.speaker_mailer['user_name']
    subject    subject
    sent_on    Time.now
    body       body_text
  end
end
