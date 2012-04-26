class SpeakerMailer < ActionMailer::Base

  # Provide ::raw_snippet_for
  include SnippetsHelper

  # Provide ::strip_tags
  include ActionView::Helpers::SanitizeHelper

  def self.configured?
    return false unless SECRETS.speaker_mailer
    hostname = SECRETS.speaker_mailer['address']
    return(hostname && hostname != 'test')
  end

  def clean_snippet(slug)
    text = raw_snippet_for(slug)
    text = text.gsub(/<br>/, "\n")
    strip_tags(text)
  end

  def speaker_email(subject_snippet, body_snippet, proposal)
    unless self.class.configured?
      raise ArgumentError, "Email settings for 'speaker_mailer' must be set in 'config/secrets.yml'"
    end
    recipients proposal.mailto_emails
    from       SECRETS.speaker_mailer['from'] || SECRETS.speaker_mailer['user_name']
    sent_on    Time.now
    template   'speaker_email'
    subject    clean_snippet(subject_snippet)
    body       :body_text => clean_snippet(body_snippet),
               :proposal => proposal
  end

  def speaker_accepted_email(proposal)
    speaker_email('proposals_acceptance_email_subject', 'proposals_acceptance_email_text', proposal)
  end

  def speaker_rejected_email(proposal)
    speaker_email('proposals_rejected_email_subject', 'proposals_rejected_email_text', proposal)
  end
end
