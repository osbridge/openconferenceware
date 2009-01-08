module ProposalsHelper
  def required
    '<span class="required-field">*</span>'
  end

  def private_field
    content_tag :span, "%", :class => "private-field"
  end
end
