class TestRest
  include Shutl::Resource::Rest
  base_uri 'http://host'
  resource_id :a
end

