require 'logger'

module Shutl::Rest

  class << self
    def logger
      @logger ||= Logger.new($stdin)
    end

    def configure
      yield self
    end

    def logger=(logger)
      @logger = logger
    end
  end
end
