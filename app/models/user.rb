# == Schema Information
# Schema version: 20120427185014
#
# Table name: users
#
#  id                        :integer(4)      not null, primary key
#  login                     :string(255)     
#  email                     :string(255)     
#  crypted_password          :string(40)      
#  salt                      :string(40)      
#  admin                     :boolean(1)      
#  created_at                :datetime        
#  updated_at                :datetime        
#  remember_token            :string(255)     
#  remember_token_expires_at :datetime        
#  using_openid              :boolean(1)      
#  affiliation               :string(128)     
#  biography                 :text            
#  website                   :string(1024)    
#  complete_profile          :boolean(1)      
#  photo_file_name           :string(255)     
#  photo_content_type        :string(255)     
#  photo_file_size           :integer(4)      
#  first_name                :string(255)     
#  last_name                 :string(255)     
#  blog_url                  :string(255)     
#  identica                  :string(255)     
#  twitter                   :string(255)     
#  selector                  :boolean(1)      
#

require 'digest/sha1'
class User < ActiveRecord::Base
  #---[ Mixins ]----------------------------------------------------------

  include SerializersMixin
  include NormalizeUrlMixin
  include SettingsCheckersMixin
  include PublicAttributesMixin
  set_public_attributes \
    :id,
    :login,
    :fullname,
    :created_at,
    :updated_at,
    :affiliation,
    :biography,
    :website,
    :complete_profile,
    :twitter,
    :identica,
    :blog_url,
    :label,
    :label_with_id

  #---[ Associations ]----------------------------------------------------

  has_and_belongs_to_many :proposals do
    def ids
      self.map(&:id).join(', ')
    end
  end

  has_many :user_favorites, :dependent => :destroy
  has_many :favorites, :through => :user_favorites, :source => :proposal do
    def proposals
      self
    end
  end
  has_many :selector_votes

  #---[ Attributes ]------------------------------------------------------

  # Virtual attribute for the unencrypted password
  attr_accessor :password

  # Protected fields
  attr_protected *[
    :admin,
    :selector,
    :id,
    :login,
    :complete_profile,
  ]

  #---[ Validations ]-----------------------------------------------------

  before_validation :add_salt
  before_save :encrypt_password

  validates_presence_of     :salt
  validates_length_of       :salt,     :minimum => 40

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40,  :unless => :using_openid?
  validates_uniqueness_of   :login,                       :case_sensitive => false

  validates_presence_of     :password,                    :if => :password_required?
  validates_presence_of     :password_confirmation,       :if => :password_required?
  validates_length_of       :password, :within => 4..40,  :if => :password_required?
  validates_confirmation_of :password,                    :if => :password_required?

  validates_presence_of     :email,                       :if => :complete_profile?
  validates_length_of       :email,    :within => 3..100, :if => :complete_profile?

  validates_presence_of     :first_name,                  :if => :complete_profile?
  validates_presence_of     :last_name,                   :if => :complete_profile?
  validates_presence_of     :email,                       :if => :complete_profile?
  validates_presence_of     :biography,                   :if => :complete_profile?

  validate :url_validator

  #---[ Scopes ]----------------------------------------------------------

  default_order = { :order => 'lower(last_name), lower(first_name)' }

  named_scope :by_name, default_order
  named_scope :complete_profiles, { :conditions => {:complete_profile => true} }.reverse_merge!(default_order)

  named_scope :submitted_to, lambda {|event| {
    :select => 'DISTINCT users.id, users.*',
    :joins => :proposals,
    :conditions => ['proposals.event_id = ?', event.id] }.reverse_merge!(default_order)
  }

  named_scope :speaking_at, lambda {|event| {
    :select => 'DISTINCT users.id, users.*',
    :joins => :proposals,
    :conditions => ['proposals.status = "confirmed" AND proposals.event_id = ?', event.id] }.reverse_merge!(default_order)
  }

  #---[ CSV export ]------------------------------------------------------

  comma :brief do
    first_name
    last_name
    affiliation
    email
  end

  base_comma_attributes = lambda {
    id
    first_name
    last_name
    affiliation
    biography
    photo :url => 'Photo'
    website
    twitter
    identica
    blog_url
    created_at :xmlschema => 'Created'
    updated_at :xmlschema => 'Updated'
    proposals :ids => 'Session ids'
  }

  comma :full do
    login
    email
    instance_eval &base_comma_attributes
  end

  comma :public do
    instance_eval &base_comma_attributes
  end

  #---[ PaperClip avatar images ]-----------------------------------------

  has_attached_file :photo,
    :styles => {
      :profile => '200x400>',
      :avatar => '48x48#'
    }

  #---[ Methods ]---------------------------------------------------------

  # Return first admin user or a nil
  def self.find_first_admin
    self.find(:first, :conditions => {:admin => true})
  end

  # Return first non-admin user or a nil
  def self.find_first_non_admin
    self.find(:first, :conditions => {:admin => false})
  end

  # Returns user if they're authenticated by their login name and unencrypted password, else a nil.
  def self.authenticate(login, password)
    if user = self.find_by_login(login) and user.authenticated?(password)
      return user
    else
      return nil
    end
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    raise ArgumentError, "Password and salt must be specified." if password.blank? || salt.blank?
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user's salt
  def encrypt(password)
    raise ArgumentError, "Salt must be specified." if self.salt.blank?
    self.class.encrypt(password, self.salt)
  end

  # Is this user authenticated by this unencrypted password?
  def authenticated?(password)
    self.crypted_password == self.encrypt(password)
  end

  # Does this user have a remember token?
  def remember_token?
    self.remember_token_expires_at && Time.now.utc < self.remember_token_expires_at
  end

  # Remember this user for the default period of time.
  def remember_me
    self.remember_me_for 2.weeks
  end

  # Remember user for a given amount of time (e.g. 2.weeks).
  def remember_me_for(time)
    self.remember_me_until time.from_now
  end

  # Remember user until a given time(e.g. 2.weeks.from_now).
  def remember_me_until(time)
    token = self.encrypt([self.id, self.login, self.remember_token_expires_at, Time.now.to_i, (1..10).map{rand.to_s}].join('|'))
    self.update_attributes(
      :remember_token_expires_at => time,
      :remember_token => token
    )
  end

  # Forget the user's remember token.
  def forget_me
    self.update_attributes(
      :remember_token_expires_at => nil,
      :remember_token            => nil
    )
  end

  def change_password!(password)
    self.password = self.password_confirmation = password
    self.save!
  end

  # Create and return a user from the given OpenID URL and its registration information.
  def self.create_from_openid!(identity_url, registration)
    user = User.new
    user.login = identity_url
    user.email = registration["email"]
    user.fullname = registration["fullname"]
    user.using_openid = true
    user.add_salt
    user.save!
    return user
  end

  # Return user matching the given OpenID URL.
  def self.find_by_openid(identity_url)
    self.find(:first, :conditions => {:login => identity_url, :using_openid => true})
  end

  # Return a User instance for a value, which can either be a User,
  # Symbol of the User's login, or a String or Integer id for the User.
  def self.get(value)
    case value
    when User
      return value
    when Symbol
      return User.find_by_login(value.to_s)
    when Integer, String
      return User.find(value.to_i)
    else
      raise TypeError, "Unknown argument type #{value.class.to_s.inspect} with value #{value.inspect}"
    end
  end

  # Return a label for the user.
  def label
    name = self.fullname.blank? ? nil : self.fullname
    return name || (self.using_openid? ? "User ##{self.id} at #{URI.parse(login).host}" : self.login)
  end

  # Return a label for the user with their user ID.
  def label_with_id
    return "#{self.label} (#{self.id})"
  end

  # Return string with the user's full name, or as much of it as possible, or a nil.
  def fullname
    return [self.first_name, self.last_name].compact.join(" ") if ! self.first_name.blank? || ! self.last_name.blank?
  end

  # Set the user's first and last name by splitting a single string.
  def fullname=(value)
    if value.present?
      parts = value.split(" ")
      self.first_name = parts[0..-2].join(' ')
      self.last_name = parts.last
    end
  end

  # Alias for #fullname for providing common profile methods.
  def presenter
    return self.fullname
  end

  # Return the user name and maybe their affiliation
  def fullname_and_affiliation
    return [self.fullname, self.affiliation].reject(&:blank?).join(' - ')
  end

  # Normalize the user's twitter username when reading it
  def normalized_twitter
    if self.twitter
      return self.twitter.sub(/^https?:\/\/(?:www\.)?twitter.com\//i, '').sub(/^@/, '')
    end
  end

  # Return the user's twitter profile.
  def twitter_url
    if self.twitter
      return "http://twitter.com/#{self.normalized_twitter}"
    end
  end

  # Return the user's identica profile.
  def identica_url
    if self.identica
      return "http://identi.ca/#{self.identica}"
    end
  end

  def sessions
    return self.proposals.confirmed
  end

  # Add encryption salt to record if needed.
  def add_salt
    self.salt ||= Digest::SHA1.hexdigest([self.id, self.login, Time.now.to_i, (1..10).map{rand.to_s}].join('|'))
  end

protected

  # Create crypted password from plain-text password entered by user, if provided.
  def encrypt_password
    return if self.password.blank?
    self.add_salt
    self.crypted_password = self.encrypt(self.password)
  end

  # Does this user require a password to be defined?
  def password_required?
    #IK# !using_openid? && (crypted_password.blank? || !password.blank?)
    if self.using_openid
      false # OpenID-based users don't need passwords
    else
      if self.crypted_password.blank?
        true # Login-based users without crypted_passwords must have transient fields checked
      else
        false # Login-based user already has a crypted_password, and doesn't need transient fields checked
      end
    end
  end

  # Does this user require an email to be defined?
  def email_required?
    if user_profiles?
      if self.complete_profile?
        not self.email.blank?
      else
        true
      end
    else
      not self.using_openid?
    end
  end

  # Ensure URLs are valid, else add validation errors.
  def url_validator
    return validate_url_attribute(:website, :blog_url)
  end
  
end
