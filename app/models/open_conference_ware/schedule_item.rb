module OpenConferenceWare

  # == Schema Information
  #
  # Table name: schedule_items
  #
  #  id          :integer          not null, primary key
  #  title       :string(255)
  #  excerpt     :text
  #  description :text
  #  start_time  :datetime
  #  duration    :integer
  #  event_id    :integer
  #  room_id     :integer
  #  created_at  :datetime
  #  updated_at  :datetime
  #

  class ScheduleItem < OpenConferenceWare::Base

    # Associations
    belongs_to :event
    belongs_to :room

    # Provides #overlaps?
    include ScheduleOverlapsMixin

    # Public attributes for export
    include PublicAttributesMixin
    set_public_attributes :id, :title, :excerpt, :description, :start_time, :end_time, :duration,
      :event_id, :event_title,
      :room_id, :room_title,
      :created_at, :updated_at

    # Return the time this session ends.
    def end_time
      if self.start_time
        self.start_time + (self.duration || 0).minutes
      else
        nil
      end
    end

    #---[ Accessors for getting the titles of related objects ]-------------

    def room_title
      return self.room.try(:name)
    end

    def event_title
      return self.event.try(:slug)
    end
    alias_method :event_slug, :event_title
  end
end
