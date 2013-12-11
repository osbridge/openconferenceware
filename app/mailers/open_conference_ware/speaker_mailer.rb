module OpenConferenceWare
  class SpeakerMailer < ActionMailer::Base

    # Provide ::raw_snippet_for
    include SnippetsHelper

    # Provide ::strip_tags
    include ActionView::Helpers::SanitizeHelper
    extend  ActionView::Helpers::SanitizeHelper::ClassMethods


    def self.configured?
      if !Rails.env.test? && (OpenConferenceWare.email.blank? || OpenConferenceWare.email['action_mailer'].blank? || OpenConferenceWare.email['default_from_address'] == 'test')
        return false
      else
        return true
      end
    end

    def clean_snippet(slug)
      text = raw_snippet_for(slug)
      text = text.gsub(/<br>/, "\n")
      strip_tags(text)
    end

    def speaker_email(subject_snippet, body_snippet, proposal)
      unless self.class.configured?
        raise ArgumentError, "Email settings must be set in 'config/secrets.yml'"
      end

      @proposal = proposal
      @body_text  = clean_snippet(body_snippet)

      mail(
        to: proposal.mailto_emails,
        bcc: OpenConferenceWare.default_bcc_address,
        from: OpenConferenceWare.default_from_address,
        subject: clean_snippet(subject_snippet),
        template_name: 'speaker_email'
      )
    end

    def speaker_accepted_email(proposal)
      speaker_email('proposals_acceptance_email_subject', 'proposals_acceptance_email_text', proposal)
    end

    def speaker_rejected_email(proposal)
      speaker_email('proposals_rejected_email_subject', 'proposals_rejected_email_text', proposal)
    end
  end
end
