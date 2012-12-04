require 'rails/engine'
require 'shutl_resource/configuration'
require 'shutl_resource/rest_resource'
require 'shutl_resource/rest_resource_class_methods'
require 'shutl_resource/access_token_request'
require 'shutl_resource/rest_resource_class_methods'
require 'shutl_resource/converter'
require 'shutl_resource/no_converter'
require 'shutl_resource/engine'
require 'shutl_resource/application_controller_methods'
require 'rack/oauth2'

class ShutlResource::Error < ::IOError
  attr_reader :response

  def initialize message, http_response
    @response = http_response

    super message #it really is rather spot on, why thanks for saying, kind sir.
  end
end

module ShutlResource
  # This NoQuotesGenerated is shutl specific corresponding to HTTP status 299.
  # We had a good think about what the correct HTTP code is for the case that
  # the request is fine, but we couldn't generate any quotes. It doesn't feel
  # like a 4xx or a 5xx, but not quite like a 2xx either. Comments/thoughts
  # more than welcome.
  ShutlResource::NoQuotesGenerated  = Class.new ShutlResource::Error

  ShutlResource::BadRequest         = Class.new ShutlResource::Error
  ShutlResource::UnauthorizedAccess = Class.new ShutlResource::Error
  ShutlResource::ForbiddenAccess    = Class.new ShutlResource::Error
  ShutlResource::ResourceNotFound   = Class.new ShutlResource::Error
  ShutlResource::ResourceConflict   = Class.new ShutlResource::Error
  ShutlResource::ResourceGone       = Class.new ShutlResource::Error
  ShutlResource::ResourceInvalid    = Class.new ShutlResource::Error
  ShutlResource::ServerError        = Class.new ShutlResource::Error
  ShutlResource::ServiceUnavailable = Class.new ShutlResource::Error

  extend self

  delegate :logger, :logger=, to: Configuration

  def configure(*args, &block)
    Configuration.configure(*args, &block)
  end
end


