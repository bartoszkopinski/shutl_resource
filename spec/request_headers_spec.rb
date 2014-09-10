require 'spec_helper'

describe Shutl::Resource::Rest do
  let(:expected_headers) do
    {
      headers:
        {
          'Accept'                => 'application/json',
          'Accept-Encoding'       => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization'         => 'some auth',
          'Content-Type'          => 'application/json+consumer',
          'User-Agent'            => "Shutl Resource Gem v#{Shutl::Resource::VERSION}",
          'Consumer-Access-Token' => 'ConsumerAccessToken'
        }
    }
  end

  let(:response_headers) do
    { 'Accept'       => 'application/json',
      'Content-Type' => 'application/json',
      'User-Agent'   => "Shutl Resource Gem v#{Shutl::Resource::VERSION}" }
  end

  let(:resource) { TestRest.new(a: 'a', b: 2) }

  let(:headers) {
    {
      authorization:         "some auth",
      content_type:          "application/json+consumer",
      consumer_access_token: "ConsumerAccessToken"
    }
  }

  describe 'prepends Bearer if auth is passed in for authorization' do
    let(:resource) { TestSingularResource.new }
    let(:expected_headers) {
      {
        'Accept'                => 'application/json',
        'Accept-Encoding'       => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Authorization'         => 'Bearer some_auth',
        'Content-Type'          => 'application/json',
        'User-Agent'            => "Shutl Resource Gem v#{Shutl::Resource::VERSION}",
      }
    }
    before do
      @request = stub_request(:get, 'http://host/test_singular_resource')
                 .with(expected_headers)
                 .to_return(:status  => 200,
                            :body    => '{"test_singular_resource": { "a": "a", "b": 2 }}',
                            :headers => response_headers)
    end
    it 'queries the endpoint' do
      TestSingularResource.find(auth: "some_auth")
      @request.should have_been_requested
    end

  end


  describe '#find' do
    context "with a singular resource" do
      let(:resource) { TestSingularResource.new }

      before do
        @request = stub_request(:get, 'http://host/test_singular_resource')
                   .with(expected_headers)
                   .to_return(:status  => 200,
                              :body    => '{"test_singular_resource": { "a": "a", "b": 2 }}',
                              :headers => response_headers)

      end

      it 'queries the endpoint' do
        TestSingularResource.find(headers: headers)
        @request.should have_been_requested
      end
    end
  end

  describe ".create" do

    context "With the setting to not raise exceptions" do
      let(:resource) { TestSingularResource.new }
      let(:attributes) { { :a => 1 } }
      let(:body) { { test_singular_resource: { a: 1 } }.to_json }
      before do
        post_headers = expected_headers[:headers].except("Accept-Encoding")
        @request = stub_request(:post, 'http://host/test_singular_resources')
                   .with(post_headers.merge(body: body))
                   .to_return(:status  => 200,
                              :headers => response_headers)
      end

      it 'queries the endpoint' do
        TestSingularResource.create(attributes, headers: headers)
        @request.should have_been_requested
      end
    end
  end

  describe "#destroy" do
    let(:destroy_headers) { expected_headers[:headers].except("Accept-Encoding") }

    before do
      @request = stub_request(:delete, 'http://host/test_singular_resources/a')
                 .with(destroy_headers)
    end

    it 'queries the endpoint' do
        TestSingularResource.destroy(id: 'a')
        @request.should have_been_requested
    end
  end

  describe "#save" do
    let(:save_headers) { expected_headers[:headers].except("Accept-Encoding") }
    before do
      @request = stub_request(:put, 'http://host/test_rests/a')
                 .with(save_headers)
    end

    it 'queries the endpoint' do
      resource.save
      @request.should have_been_requested
    end
  end

  describe '#update!' do
    let(:update_headers) { expected_headers[:headers].except("Accept-Encoding") }
    let(:attributes) { { a: 'a', b: 'b' } }
    let(:body) { { test_rest: { a: "a", b: "b", id: "a" } }.to_json }

    before do
      @request = stub_request(:put, "http://host/test_rests/a").
        with(:body    => body,
             :headers => update_headers).
        to_return(:status => 200, :body => "", :headers => {})
    end

    it 'queries the endpoint' do
      resource.update!(attributes, headers: headers)
      @request.should have_been_requested
    end
  end

  describe '#all' do
    let(:body) { { test_rests: [{ a: "a", b: 2 }]}.to_json }

    before do
      @request = stub_request(:get, 'http://host/test_rests')
                 .with(expected_headers)
                 .to_return(:status => 200, body: body,:headers => headers)
    end

    it 'queries the endpoint' do
      TestRest.all headers: headers
      @request.should have_been_requested
    end
  end
end