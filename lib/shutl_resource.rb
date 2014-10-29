module Shutl
end

require 'faraday'
require 'faraday_middleware'

require 'shutl_auth'
require 'shutl/resource/version'
require 'shutl/resource/configuration'
require 'shutl/resource/default_logger'
require 'shutl/resource/rest'
require 'shutl/resource/rest_class_methods'
require 'shutl/resource/errors'

Faraday::Middleware.register_middleware :default_logger => :DefaultLogger


module Shutl::Resource
  extend self

  delegate :logger, :logger=, :base_uri, :base_uri=, :proxy_uri, :proxy_uri=, to: Configuration

  def configure(*args, &block)
    Configuration.configure(*args, &block)
  end
end


