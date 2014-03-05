module OpenConferenceWare
  # = PublicAttributesMixin
  #
  # The PublicAttributesMixin provides a simple way to mark attributes as
  # publicly-known and export only their data. This mixin is useful for
  # selectively exposing attributes to AJAX methods and exporter programs where
  # you do not want to publish confidential data, such as email addresses,
  # passwords, etc.
  #
  # == Usage
  #
  # Include the mixin and set the public attribute names:
  #
  #   class User < ActiveRecord::Base
  #     include PublicAttributesMixin
  #     set_public_attributes :id, :first_name, :last_name
  #   end
  #
  # Export data for a record:
  #
  #   user = User.first
  #   puts user.public_attributes.inspect
  #   # => {"id" => 123, "first_name" => "Bubba", "last_name" => "Smith"}
  module PublicAttributesMixin
    def self.included(receiver)
      receiver.send(:cattr_accessor, :public_attribute_keys)
      receiver.send("public_attribute_keys=", [])
      receiver.send(:extend, ClassMethods)
      receiver.send(:include, InstanceMethods)
    end

    module ClassMethods
      # Set the names of public attributes. Can specify attributes using strings
      # or symbols, and as an array or arguments.
      def set_public_attributes(*args)
        self.public_attribute_keys = [args].flatten.map(&:to_sym)
      end
    end

    module InstanceMethods
      # Return a hash of public attributes.
      def public_attributes
        return self.public_attribute_keys.inject({}) do |result, key|
          result[key.to_s] = self.send(key) if self.public_attribute_keys.include?(key.to_sym)
          result
        end
      end

      def serializable_hash(options={})
        if options && (options.keys & [:only, :except, :methods, :include]).present?
          super(options)
        else
          public_attributes
        end
      end

      def to_xml(options={})
        serializable_hash(options).to_xml(options)
      end
    end
  end
end
