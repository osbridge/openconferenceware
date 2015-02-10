module OpenConferenceWare

  # == Schema Information
  #
  # Table name: users
  #
  #  id                 :integer          not null, primary key
  #  email              :string(255)
  #  salt               :string(40)
  #  admin              :boolean          default(FALSE)
  #  created_at         :datetime
  #  updated_at         :datetime
  #  affiliation        :string(128)
  #  biography          :text
  #  website            :string(1024)
  #  complete_profile   :boolean
  #  photo_file_name    :string(255)
  #  photo_content_type :string(255)
  #  photo_file_size    :integer
  #  first_name         :string(255)
  #  last_name          :string(255)
  #  blog_url           :string(255)
  #  identica           :string(255)
  #  twitter            :string(255)
  #  selector           :boolean          default(FALSE)
  #

  require 'digest/sha1'
  class User < OpenConferenceWare::Base
    #---[ Mixins ]----------------------------------------------------------

    include NormalizeUrlMixin
    include SettingsCheckersMixin
    include PublicAttributesMixin
    set_public_attributes \
      :id,
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

    has_many :authentications

    has_and_belongs_to_many :proposals do
      def ids
        self.map(&:id).join(', ')
      end
    end

    has_many :user_favorites, dependent: :destroy
    has_many :favorites, through: :user_favorites, source: :proposal do
      def proposals
        self
      end
    end
    has_many :selector_votes

    #---[ Validations ]-----------------------------------------------------

    validates_presence_of     :email,                       if: :email_required?
    validates_length_of       :email,    within: 3..100, if: :email_required?

    validates_presence_of     :first_name,                  if: :complete_profile?
    validates_presence_of     :last_name,                   if: :complete_profile?
    validates_presence_of     :email,                       if: :complete_profile?
    validates_presence_of     :biography,                   if: :complete_profile?

    validate :url_validator

    #---[ Scopes ]----------------------------------------------------------

    cols_for_name_sort = 'lower(open_conference_ware_users.last_name), lower(open_conference_ware_users.first_name)'
    scope :by_name, lambda { order(cols_for_name_sort) }
    scope :default_order, lambda { by_name }
    scope :complete_profiles, lambda { where(complete_profile: true).default_order }

    scope :submitted_to, lambda {|event|
      select("open_conference_ware_users.id, open_conference_ware_users.*, #{cols_for_name_sort}").
        joins(:proposals).
        where('open_conference_ware_proposals.event_id = ?', event.id).
        default_order.
        uniq
    }

    scope :speaking_at, lambda {|event|
      select("open_conference_ware_users.id, open_conference_ware_users.*, #{cols_for_name_sort}").
        joins(:proposals).
        where("open_conference_ware_proposals.status = 'confirmed' AND open_conference_ware_proposals.event_id = ?", event.id).
        default_order.
        uniq
    }

    #---[ CSV export ]------------------------------------------------------

    comma :brief do
      first_name
      last_name
      affiliation
      email
    end

    comma :full do
      email
      id
      first_name
      last_name
      affiliation
      biography
      website
      twitter
      identica
      blog_url
      created_at 'Created'
      updated_at 'Updated'
      proposals ids: 'Session ids'
    end

    comma :public do
      id
      first_name
      last_name
      affiliation
      biography
      website
      twitter
      identica
      blog_url
      created_at 'Created'
      updated_at 'Updated'
      proposals ids: 'Session ids'
    end

    #---[ PaperClip avatar images ]-----------------------------------------

    has_attached_file :photo,
      path: ":rails_root/public/system/:attachment/:id/:style/:filename",
      url: "/system/:attachment/:id/:style/:filename",
      styles: {
        profile: '200x400>',
        avatar: '48x48#'
      }

    validates_attachment_content_type :photo,
      :content_type => /\Aimage\/.*\Z/,
      :unless => Proc.new{|r| r.photo_content_type.blank? }

    #---[ Methods ]---------------------------------------------------------

    def self.create_from_authentication(auth)
      create! do |user|
        user.email = auth.email

        if auth.has_first_and_last_name?
          user.first_name = auth.info['first_name']
          user.last_name  = auth.info['last_name']
        else
          user.fullname = auth.name
        end

        user.biography = auth.info['description']
        user.website = auth.first_url
        user.authentications << auth

        user.save
      end
    end

    def role
      admin? ? :admin : :default
    end

    # Return a User instance for a value, which can either be a User,
    # or a String or Integer id for the User.
    def self.get(value)
      case value
      when User
        return value
      when Integer, String
        return User.find(value.to_i)
      else
        raise TypeError, "Unknown argument type #{value.class.to_s.inspect} with value #{value.inspect}"
      end
    end

    # Return a label for the user.
    def label
      name = self.fullname.blank? ? nil : self.fullname
      return name || "User ##{self.id}"
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
        if parts.length > 1
          self.first_name = parts[0..-2].join(' ')
          self.last_name = parts.last
        else
          self.first_name = parts.first
        end
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

    # For use in merging duplicate user records
    def take_associations_from(dup)
      self.authentications += dup.authentications
      self.user_favorites += dup.user_favorites
      self.selector_votes += dup.selector_votes
      dup.proposals.each { |p| p.add_user(self); p.remove_user(dup) }
    end

  protected

    # Does this user require an email to be defined?
    def email_required?
      user_profiles? && self.complete_profile?
    end

    # Ensure URLs are valid, else add validation errors.
    def url_validator
      return validate_url_attribute(:website, :blog_url)
    end

  end
end
