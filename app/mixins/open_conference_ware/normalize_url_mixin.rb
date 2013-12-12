module OpenConferenceWare
  module NormalizeUrlMixin
    def self.included(mixee)
      mixee.send(:extend, ClassMethods)
      mixee.send(:include, ClassMethods)
    end

    module ClassMethods
      # Return a normalized URL, with the scheme prefix added, or raise an
      # URI::InvalidURIError if invalid.
      def normalize_url!(url)
        uri = URI.parse(url.strip)
        uri.scheme = 'http' unless ['http','ftp'].include?(uri.scheme) || uri.scheme.nil?
        return URI.parse(uri.scheme.nil? ? 'http://'+url.strip : uri.to_s).normalize.to_s
      end

      # Validate that +attributes+ each contain a valid URL or are blank. If any
      # are invalid, returns false. Invalid attributes will be marked with an
      # ActiveRecord validation error.
      def validate_url_attribute(*attributes)
        valid = true
        for attribute in [attributes].flatten
          value = self.read_attribute(attribute)
          next if value.blank?
          begin
            url = self.normalize_url!(value)
            self.send("#{attribute}=", url)
          rescue URI::InvalidURIError => e
            self.errors.add(attribute, 'is invalid')
            valid = false
          end
        end
        return valid
      end
    end

    include ClassMethods
    extend ClassMethods
  end
end
