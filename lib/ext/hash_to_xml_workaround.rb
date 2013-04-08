class Hash
  def to_xml_workaround(*args)
    self.clone.tap do |result|
      result.each_pair do |key, value|
        case result[key]
        when Array
          result[key] = value.each_with_index.to_a.inject({}){|s,v| s["index_#{v.last}"] = v.first; s}
        end
      end
    end
  end
end
