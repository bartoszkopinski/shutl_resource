require 'rails/engine'

module Shutl
end

require 'shutl_auth'
require 'shutl/resource/configuration'
require 'shutl/resource/rest'
require 'shutl/resource/rest_class_methods'
require 'shutl/resource/errors'

module Shutl::Resource
  extend self

  delegate :logger, :logger=, to: Configuration

  def configure(*args, &block)
    Configuration.configure(*args, &block)
  end
end


