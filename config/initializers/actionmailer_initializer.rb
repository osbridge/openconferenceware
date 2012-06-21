# Setup ActionMailer based on the "config/secrets.yml" information:

require "smtp_tls"

if SECRETS.email
  if SECRETS.email['action_mailer'].kind_of?(Hash)
    for key, value in SECRETS.email['action_mailer']
      key = key.to_sym
      value = HashWithIndifferentAccess.new(value) if value.is_a?(Hash)

      # Certain things are expected to be symbols…
      if key == :delivery_method
        value = value.to_sym
        next if RAILS_ENV == "test"
      elsif key == :smtp_settings
        if value.kind_of?(Hash) && value.has_key?(:authentication)
          value[:authentication] = value[:authentication].to_sym
        end
      end

      ActionMailer::Base.send("#{key}=", value)
    end
  end

  # We support sending using https://github.com/elevatedrails/emailthing_collector
  if SECRETS.email['emailthing_api_key']
    Emailthing.api_key = SECRETS.email['emailthing_api_key']
  end
end
