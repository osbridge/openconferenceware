module OpenConferenceWare

  # == Schema Information
  #
  # Table name: tracks
  #
  #  id          :integer          not null, primary key
  #  title       :string(255)
  #  description :text
  #  color       :string(255)
  #  event_id    :integer
  #  created_at  :datetime
  #  updated_at  :datetime
  #  excerpt     :text
  #

  class Track < OpenConferenceWare::Base

    # Associations
    belongs_to :event
    has_many :proposals, dependent: :nullify

    # Validations
    validates_presence_of \
      :color,
      :description,
      :excerpt,
      :event_id,
      :title

    def <=>(against)
      self.title <=> (against.nil? ? '' : against.title)
    end

    def color
      (stored_color = read_attribute(:color)).nil? ? nil : Color::RGB.from_html(stored_color)
    end

    def color=(value)
      case value
      when Color::RGB
        new_color = value
      when String
        new_color = Color::RGB.from_html(value)
      else
        raise TypeError
      end
      write_attribute(:color,new_color.html)
    rescue ArgumentError
      write_attribute(:color, nil)
      errors.add(:color, "is not a recognized HTML color")
    end
  end
end
