require 'color'

# Make colors serializable.
module Color
  class RGB
    def to_s
      self.html.to_s
    end

    def to_json(*args)
      self.to_s
    end

    def to_xml(*args)
      self.to_s
    end
  end
end
