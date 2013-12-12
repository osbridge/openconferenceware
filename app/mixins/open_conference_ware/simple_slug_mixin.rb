module OpenConferenceWare
  module SimpleSlugMixin
    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        class << self
          alias_method_chain :find, :slug
        end
      end
    end

    def to_param
      slug
    end

    module ClassMethods
      def find_with_slug(id, options = {})
        if id.is_a?(Symbol) || id.to_s =~ /\A\d+\Z/
          find_without_slug(id, options)
        else
          find_by_slug(id, options)
        end
      end
    end
  end
end
