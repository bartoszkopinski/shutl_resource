require 'shutl_resource'
require 'webmock/rspec'

require 'support/test_resource'
require 'support/double_logger'


require 'vcr'


VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = false
  c.default_cassette_options = {
    record: ENV['VCR_RERECORD'].present? ? :all : :once
  }
end


