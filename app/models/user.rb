# == Schema Information
# Schema version: 20090616061006
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
#

require 'digest/sha1'
class User < ActiveRecord::Base
  # Mixins
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

  # Associations
  has_and_belongs_to_many :proposals

  has_many :user_favorites
  has_many :favorites, :through => :user_favorites, :source => :proposal do
    def proposals
      self
    end
  end

  # Virtual attribute for the unencrypted password
  attr_accessor :password

  # Triggers
  before_save :encrypt_password

  # Protected fields
  attr_protected *[
    :admin,
    :id,
    :login,
    :complete_profile,
  ]

  # Validations
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

  default_order = { :order => 'lower(last_name), lower(first_name)' }

  # Scopes
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

  # CSV Export

  comma :brief do
    first_name
    last_name
    affiliation
    email
  end

  comma :full do
    id
    login
    first_name
    last_name
    affiliation
    email
    biography
    photo :url => "Photo"
    website
    twitter
    identica
    blog_url
    created_at :xmlschema => "Created"
    updated_at :xmlschema => "Updated"
  end

  # Return first admin user or a nil
  def self.find_first_admin
    self.find(:first, :conditions => {:admin => true})
  end

  # Return first non-admin user or a nil
  def self.find_first_non_admin
    self.find(:first, :conditions => {:admin => false})
  end

  # Photo Attachments
  has_attached_file :photo,
    :styles => {
      :profile => "200x400>",
      :avatar => "48x48!"
    }

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
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
    return self.fullname.with{blank? ? nil : self} || (self.using_openid? ? "User ##{self.id} at #{URI.parse(login).host}" : self.login)
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
    self.first_name = value.ergo{split(" ")[0..-2].join(' ')}
    self.last_name = value.ergo{split(" ").last}
  end

  # Alias for #fullname for providing common profile methods.
  def presenter
    return self.fullname
  end

  # Return the user name and maybe their affiliation
  def fullname_and_affiliation
    return [self.fullname, self.affiliation].reject(&:blank?).join(' - ')
  end

  # Return the user's twitter profile.
  def twitter_url
    if self.twitter
      return "http://twitter.com/#{self.twitter}"
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

protected

  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
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
