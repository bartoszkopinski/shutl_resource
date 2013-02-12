require 'logger'

module Shutl::Resource

  class << self
    attr_writer :raise_exceptions_on_validation

    def raise_exceptions_on_validation
      if @raise_exceptions_on_validation.nil?
        @raise_exceptions_on_validation = false
      end

      @raise_exceptions_on_validation
    end
  end

  def configure(*args, &block)
    Configuration.configure(*args, &block)
  end

  module Configuration
    class << self
      def logger
        @logger ||= Logger.new($stdout)
      end

      def configure
        yield self
      end

      def logger=(logger)
        @logger = logger
      end
    end
  end
end
