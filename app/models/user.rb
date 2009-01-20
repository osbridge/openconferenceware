# == Schema Information
# Schema version: 20090118172133
#
# Table name: users
#
#  id                        :integer         not null, primary key
#  login                     :string(255)     
#  email                     :string(255)     
#  fullname                  :string(255)     
#  crypted_password          :string(40)      
#  salt                      :string(40)      
#  admin                     :boolean         
#  created_at                :datetime        
#  updated_at                :datetime        
#  remember_token            :string(255)     
#  remember_token_expires_at :datetime        
#  using_openid              :boolean         
#  affiliation               :string(128)     
#  biography                 :text(2048)      
#  website                   :string(1024)    
#  complete_profile          :boolean         
#

require 'digest/sha1'
class User < ActiveRecord::Base
  # Mixins
  include SettingsCheckersMixin

  # Associations
  has_and_belongs_to_many :proposals

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

  validates_presence_of     :fullname,                    :if => :complete_profile?
  validates_presence_of     :email,                       :if => :complete_profile?
  validates_presence_of     :biography,                   :if => :complete_profile?

  # Scopes
  named_scope :complete_profiles, :conditions => {:complete_profile => true}, :order => 'fullname asc'

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

  # Return a label for the user.
  def label
    return "#{(self.fullname.with{blank? ? nil : self}) || (self.using_openid? ? URI.parse(login).host : self.login)}"
  end

  # Return a label for the user with their user ID.
  def label_with_id
    return "#{self.label} (#{self.id})"
  end

  # Alias for #fullname for providing common profile methods.
  def presenter
    return self.fullname
  end

  # Return the user name and maybe their affiliation
  def fullname_and_affiliation
    return [self.fullname, self.affiliation].reject(&:blank?).join(' - ')
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

end
