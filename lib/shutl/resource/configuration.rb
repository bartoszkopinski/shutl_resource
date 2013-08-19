require 'logger'

module Shutl::Resource
  class << self
    attr_writer :raise_exceptions_on_validation,
                :raise_exceptions_on_no_quotes_generated

    def raise_exceptions_on_validation
      if @raise_exceptions_on_validation.nil?
        @raise_exceptions_on_validation = false
      end

      @raise_exceptions_on_validation
    end

    def raise_exceptions_on_no_quotes_generated
      if @raise_exceptions_on_no_quotes_generated.nil?
        @raise_exceptions_on_no_quotes_generated = true
      end

      @raise_exceptions_on_no_quotes_generated
    end
  end

  def configure(*args, &block)
    Configuration.configure(*args, &block)
  end

  module Configuration
    class << self
      attr_accessor :base_uri, :logger

      def configure
        yield self
      end
    end
  end
end
