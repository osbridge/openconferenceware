module OpenConferenceWare

  # == Schema Information
  #
  # Table name: session_types
  #
  #  id          :integer          not null, primary key
  #  title       :string(255)
  #  description :text
  #  duration    :integer
  #  event_id    :integer
  #  created_at  :datetime
  #  updated_at  :datetime
  #

  class SessionType < OpenConferenceWare::Base

    # Associations
    belongs_to :event
    has_many :proposals, dependent: :nullify

    # Validations
    validates_presence_of \
      :title,
      :description,
      :event_id
    validates_numericality_of :duration, if: :duration

    def <=>(against)
      self.title <=> (against.nil? ? '' : against.title)
    end
  end
end
