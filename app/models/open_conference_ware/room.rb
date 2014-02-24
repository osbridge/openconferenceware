module OpenConferenceWare

  # == Schema Information
  #
  # Table name: rooms
  #
  #  id                    :integer          not null, primary key
  #  name                  :string(255)      not null
  #  capacity              :integer
  #  size                  :string(255)
  #  seating_configuration :string(255)
  #  description           :text
  #  event_id              :integer
  #  created_at            :datetime
  #  updated_at            :datetime
  #  image_file_name       :string(255)
  #  image_content_type    :string(255)
  #  image_file_size       :integer
  #  image_updated_at      :datetime
  #

  class Room < OpenConferenceWare::Base
    # Associations
    belongs_to :event
    has_many :proposals, dependent: :nullify
    has_many :schedule_items, dependent: :nullify

    # Validations
    validates_presence_of :name, :event
    validates_numericality_of :capacity, unless: lambda{|obj| obj.capacity.blank? }

    # Image Attachment
    has_attached_file :image,
      path: ":rails_root/public/system/:attachment/:id/:style/:filename",
      url: "/system/:attachment/:id/:style/:filename",
      styles: {
        large: "650>",
        medium: "350>",
        small: "150>"
      }

    validates_attachment_content_type :image,
      :content_type => /\Aimage\/.*\Z/,
      :unless => Proc.new{|r| r.image_content_type.blank? }
  end
end
