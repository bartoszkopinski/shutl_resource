require 'rails/engine'

module Shutl
end

require 'shutl/resource/configuration'
require 'shutl/resource/rest'
require 'shutl/resource/rest_class_methods'
require 'shutl/resource/access_token_request'
require 'shutl/resource/rest_class_methods'
require 'shutl/resource/converter'
require 'shutl/resource/no_converter'
require 'shutl/resource/engine'
require 'shutl/resource/authentication'
require 'shutl/resource/errors'
require 'rack/oauth2'

module Shutl::Resource
  extend self

  delegate :logger, :logger=, to: Configuration

  def configure(*args, &block)
    Configuration.configure(*args, &block)
  end
end


