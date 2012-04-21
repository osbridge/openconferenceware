# Setup ActionMailer based on the "config/secrets.yml" information:

require "smtp_tls"

configuration = {}
if SECRETS.speaker_mailer.kind_of?(Enumerable)
  for key, value in SECRETS.speaker_mailer
    key = key.to_sym
    next if key == :from
    if key == :authentication
      value = value.to_sym
    end
    configuration[key] = value
  end
end

ActionMailer::Base.smtp_settings = configuration
