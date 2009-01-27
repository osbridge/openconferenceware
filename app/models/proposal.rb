# == Schema Information
# Schema version: 20081213032512
#
# Table name: proposals
#
#  id                 :integer         not null, primary key
#  user_id            :integer         
#  presenter          :string(255)     
#  affiliation        :string(255)     
#  email              :string(255)     
#  url                :string(255)     
#  bio                :string(255)     
#  title              :string(255)     
#  description        :string(255)     
#  publish            :boolean         
#  agreement          :boolean         default(TRUE)
#  created_at         :datetime        
#  updated_at         :datetime        
#  event_id           :integer         
#  submitted_at       :datetime        
#  note_to_organizers :text            
#

class Proposal < ActiveRecord::Base
  # Associations
  belongs_to :user
  belongs_to :event
  has_many :comments

  # Validations
  # XXX Use better email validator?
  validates_presence_of :presenter, :email, :bio, :title, :description, :event_id
  validates_acceptance_of :agreement, :accept => true, :message => "must be accepted"

  # Protected attributes for assignment
  attr_protected :user_id, :event_id

  # Public attributes for export
  include PublicAttributesMixin
  set_public_attributes :id, :user_id, :presenter, :affiliation, :url, :bio, :title, :description, :created_at, :updated_at, :event_id, :submitted_at

  # Caching
  include CacheLookupsMixin
  cache_lookups_for :id, :order => 'submitted_at desc'

  # Triggers
  before_save :populate_submitted_at

  # Does this +someone+ have privileges to alter this proposal?
  def can_alter?(someone)
    someone.kind_of?(User) && (someone.admin? || someone == self.user)
  end

  # Normalize the URL.
  def url=(value)
    # TODO Should this throw an exception or invalidate object instead?
    begin
      url = URI.parse(value.strip)
      url.scheme = 'http' unless ['http','ftp'].include?(url.scheme) || url.scheme.nil?
      result = URI.parse(url.scheme.nil? ? 'http://'+value.strip : url.to_s).normalize.to_s
      write_attribute(:url, result)
    rescue URI::InvalidURIError => e
      write_attribute(:url, nil)
    end
  end

  # Return the comments as text.
  def comments_text
    return self.comments.inject("") do |string, comment| 
      string + 
        (string.empty? ? "" : "\n") +
        comment.email +
        ": " +
        comment.message
    end
  end

  # Save original created_at time because it doesn't survive database reloads.
  def populate_submitted_at
    self.submitted_at ||= self.created_at || Time.now
    return true
  end
end
