
class TestRestResource
  include Shutl::Rest::RestResource
  base_uri 'http://host'
  resource_id :a
end

