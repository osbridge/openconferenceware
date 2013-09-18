class Authentication < ActiveRecord::Base
  belongs_to :user
  attr_accessible :email, :info, :name, :provider, :uid
  serialize :info, JSON

  after_initialize do |auth|
    auth.info ||= {}
  end

  def self.find_and_update_or_create_from_auth_hash(auth_hash)
    auth = find_or_initialize_by_provider_and_uid(
      auth_hash.provider,
      auth_hash.uid
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
