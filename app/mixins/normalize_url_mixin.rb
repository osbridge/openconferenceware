module NormalizeUrlMixin
  def self.included(mixee)
    mixee.send(:extend, ClassMethods)
    mixee.send(:include, ClassMethods)
  end

  module ClassMethods
    # Return a normalized URL, with the scheme prefix added, or raise an URI::InvalidURIError if invalid.
    def normalize_url!(url)
      uri = URI.parse(url.strip)
      uri.scheme = 'http' unless ['http','ftp'].include?(uri.scheme) || uri.scheme.nil?
      return URI.parse(uri.scheme.nil? ? 'http://'+url.strip : uri.to_s).normalize.to_s
    end

    def validate_url_attribute(attribute)
      value = self.read_attribute(attribute)
      return true if value.blank?
      begin
        url = self.normalize_url!(value)
        self.write_attribute(attribute, url)
        return true
      rescue URI::InvalidURIError => e
        self.errors.add(attribute, 'is invalid')
        return false
      end
    end
  end

  include ClassMethods
  extend ClassMethods
end
