class TestSingularResource
  include Shutl::Resource::Rest
  base_uri "http://host"
  singular_resource
end
