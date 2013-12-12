module OpenConferenceWare

  # == Schema Information
  #
  # Table name: authentications
  #
  #  id         :integer          not null, primary key
  #  user_id    :integer
  #  provider   :string(255)
  #  uid        :string(255)
  #  name       :string(255)
  #  email      :string(255)
  #  info       :text
  #  created_at :datetime         not null
  #  updated_at :datetime         not null
  #

  class Authentication < OpenConferenceWare::Base
    belongs_to :user
    serialize :info, JSON

    after_initialize do |auth|
      auth.info ||= {}
    end

    def self.find_and_update_or_create_from_auth_hash(auth_hash)
      auth = find_or_initialize_by(
        provider: auth_hash.provider,
        uid: auth_hash.uid
      )

      auth.name  = auth_hash.info.name
      auth.email = auth_hash.info.email
      auth.info  = auth_hash.info

      auth.save && auth
    end

    def has_first_and_last_name?
      !!(info['first_name'] && info['last_name'])
    end

    def first_url
      info['urls'].values.first if info['urls'].is_a?(Hash)
    end
  end
end
