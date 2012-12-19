
module Shutl::Resource
  class NoLogger
    def debug(message) ; end
    def info(message) ; end
    def warn(message) ; end
    def error(message) ; end
    def fatal(message) ; end
  end
end

Shutl::Resource.configure do |config|
  config.logger = Shutl::Resource::NoLogger.new
end
