module RWikiBot
  module Errors
    class LoginError < StandardError
    end

    class RWikiBotError < StandardError
    end

    class VersionTooLowError < StandardError
    end

    class NotLoggedInError < StandardError
    end

    # An error happened while handling a response.
    class ResponseError < StandardError
      # The response object.
      attr_accessor :response

      # The underlying exception thrown
      attr_accessor :cause

      # Instantiate a new error object.
      def initialize(message, cause, response)
        super(message)
        self.cause = cause
        self.response = response
      end

      # Return the response body.
      def body
        return self.response ? self.response.body : nil
      end

      # Display error
      def to_s
        return "ResponseError:\n* Intercepted: #{self.cause}\n* Response: #{self.body}"
      end
    end
  end
end