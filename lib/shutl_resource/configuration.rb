require 'logger'

module Shutl::Resource
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
