module OpenConferenceWare
  module FieldAnnotationHelper
    def required_field
      content_tag :span, "*", class: "required-field"
    end

    def private_field
      content_tag :span, "%", class: "private-field"
    end
  end
end
