# == Schema Information
# Schema version: 20090110114924
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
#

require 'digest/sha1'
class User < ActiveRecord::Base
  # Mixins
  include SettingsCheckersMixin

  # Associations
  has_many :proposals

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
  validates_presence_of     :email,                       :if => :email_required?
  validates_length_of       :email,    :within => 3..100, :if => :email_required?

  validates_presence_of     :password,                    :if => :password_required?
  validates_presence_of     :password_confirmation,       :if => :password_required?
  validates_length_of       :password, :within => 4..40,  :if => :password_required?
  validates_confirmation_of :password,                    :if => :password_required?

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40,  :unless => :using_openid?
  validates_uniqueness_of   :login,                       :case_sensitive => false

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

  def self.create_from_openid!(identity_url, registration)
    user = User.new
    user.login = identity_url
    user.email = registration["email"]
    user.fullname = registration["fullname"]
    user.using_openid = true
    user.save!
    return user
  end

  def self.find_by_openid(identity_url)
    self.find(:first, :conditions => {:login => identity_url, :using_openid => true})
  end

  # Return a label for the user, which can be their name, login, openid or numeric id.
  def label
    if self.fullname
      self.fullname
    elsif login
      login
    elsif using_openid?
      URI.parse(login).host
    else
      self.id
    end
  end

protected

  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end

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
