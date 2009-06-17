module Vpim
  class Icalendar

    # The title of the calendar.
    def title
      @properties['X-WR-CALNAME']
    end

    # Sets the title of the calendar, displayed by some clients.
    def title=(value)
      @properties.push_unique DirectoryInfo::Field.create('X-WR-CALNAME', value)
    end

    # The time zone of the calendar
    def time_zone
      @properties['X-WR-TIMEZONE']
    end

    # Sets the time zone for entries of this calendar. (e.g. America/Los Angeles)
    def time_zone=(value)
      @properties.push_unique DirectoryInfo::Field.create('X-WR-TIMEZONE', value)
    end
  end
end

