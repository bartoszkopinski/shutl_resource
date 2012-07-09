require_relative '../lib/shutl_resource/rest_resource'
require 'webmock/rspec'

describe Shutl::RestResource do

  class TestRestResource
    include Shutl::RestResource
    base_uri 'http://host'
  end

  it 'should include the REST verb' do
    TestRestResource.should respond_to :get
    TestRestResource.should respond_to :post
    TestRestResource.should respond_to :post
    TestRestResource.should respond_to :delete
  end

  describe '#find' do
    before do
      @request = stub_request(:get, 'http://host/test_rest_resources/a').
        to_return(:status => 200, :body => '{"test_rest_resource": { "a": "value", "b": 2 }}', :headers => {})
    end

    it 'should query the endpoint' do
      TestRestResource.find('a')

      @request.should have_been_requested
    end

    it 'should parse the result of the body to create an object' do
      resource = TestRestResource.find('a')

      resource.should_not be_nil
      resource.should be_kind_of TestRestResource
    end

    it 'should assign the attributes based on the json returned' do
      resource = TestRestResource.find('a')

      resource.instance_variable_get('@a').should == 'value'
      resource.instance_variable_get('@b').should == 2
    end
  end

  describe '#all' do

    before do
      @request = stub_request(:get, 'http://host/test_rest_resources').
        to_return(:status => 200, :body => '{"test_rest_resources": [{ "a": "value", "b": 2 }]}', :headers => {})
    end

    it 'should query the endpoint' do
      TestRestResource.all

      @request.should have_been_requested
    end

    it 'should parse the result of the body to create an array' do
      resource = TestRestResource.all

      resource.should have(1).item
    end

    it 'should assign the attributes based on the json returned' do
      resource = TestRestResource.all

      resource.first.instance_variable_get('@a').should == 'value'
      resource.first.instance_variable_get('@b').should == 2
    end
  end

  describe '#create' do
    let(:resource) { TestRestResource.new(a: 'value', b: 2)  }

    before do
      @request = stub_request(:post, 'http://host/test_rest_resources').
        to_return(:status => 200, :body => '{"test_rest_resource": { "a": "value", "b": 2 }}', :headers => {})
    end

    it 'should send a post request to the endpoint' do
      resource.create

      @request.should have_been_requested

    end

    it 'should return true when the post succeeds' do
      resource.create.should eq(true)
    end

    it 'should return true if the remote server returns an error' do
      stub_request(:post, 'http://host/test_rest_resources').
         to_return(:status => 403, :body => '', :headers => {})

      resource.create.should eq(false)
    end
  end


end
