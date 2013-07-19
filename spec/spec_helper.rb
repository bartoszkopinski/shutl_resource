require 'shutl_resource'
require 'webmock/rspec'

require 'support/test_resource'
require 'support/test_resource'
require 'support/configured_base_uri_resource'
require 'support/test_singular_resource'

Shutl::Resource.configure do |config|
  config.logging_enabled = false
end
