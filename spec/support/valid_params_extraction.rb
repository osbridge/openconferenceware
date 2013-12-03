module ValidParamsExtraction
  def extract_valid_params(model)
    string_value_hash = Hash[model.attributes.map{|k,v| [k,v.to_s]}]
    comparable_attributes = string_value_hash.reject{|k,v|
      %w(created_at updated_at id event_id).include?(k.to_s)
    }

    return comparable_attributes
  end
end

RSpec.configure do |c|
  c.include ValidParamsExtraction
end

