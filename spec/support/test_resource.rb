class TestRestResource
  include ShutlResource::RestResource
  base_uri 'http://host'
  resource_id :a
end

