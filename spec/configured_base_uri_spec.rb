require 'spec_helper'

describe TestConfiguredBaseUriResource do
  let(:headers) do
    {'Accept' => 'application/json',
     'Content-Type' => 'application/json',
     'Authorization' => 'Bearer some auth'}
  end

  before do
    Shutl::Resource.configure do |config|
      config.base_uri = "http://configured"
    end
  end

  after do
    Shutl::Resource.configure do |config|
      config.base_uri = nil
    end
  end

  context "uses the configured base uri if present" do
    before do
      @request = stub_request(:get, 'http://configured/test_configured_base_uri_resources/a').
        to_return(:status  => 200,
                  :body    => '{"test_configured_base_uri_resource": { "a": "a", "b": 2 }}',
                  :headers => headers)
    end

    it 'should query the endpoint' do
      TestConfiguredBaseUriResource.find('a', auth: "some auth")

      @request.should have_been_requested
    end
  end

  context "doesnt override a resources declared base uri" do
    before do
      @request = stub_request(:get, 'http://host/test_rests/a').
        to_return(:status  => 200,
                  :body    => '{"test_rest": { "a": "a", "b": 2 }}',
                  :headers => headers)
    end

    it 'should query the endpoint' do
      TestRest.find('a', auth: "some auth")

      @request.should have_been_requested
    end
  end
end
