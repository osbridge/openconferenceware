# = SerializersMixin
#
# Mixin to ActiveRecord model classes to provide working and sanitized #to_json and #to_xml methods.
module SerializersMixin
  def to_public_attributes
    self.respond_to?(:public_attributes) ? self.public_attributes : self.attributes
  end

  def to_xml(*args)
    self.to_public_attributes.to_xml_workaround.to_xml(*args)
  end

  def to_json(*args)
    self.to_public_attributes.to_json(*args)
  end
end
