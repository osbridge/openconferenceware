module SerializersMixin
  def to_xml(*args)
    self.public_attributes.to_xml_workaround.to_xml(*args)
  end

  def to_json(*args)
    self.public_attributes.to_json(*args)
  end
end
