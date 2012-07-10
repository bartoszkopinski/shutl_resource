
class NoLogger
  def debug(message) ; end
  def info(message) ; end
  def warn(message) ; end
  def error(message) ; end
  def fatal(message) ; end
end

Shutl::Rest.configure do |config|
  config.logger = NoLogger.new
end