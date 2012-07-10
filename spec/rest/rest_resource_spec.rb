require 'spec_helper'

describe Shutl::Rest::RestResource do

  it 'should include the REST verb' do
    TestRestResource.should respond_to :get
    TestRestResource.should respond_to :post
    TestRestResource.should respond_to :post
    TestRestResource.should respond_to :delete
  end

  let(:resource) { TestRestResource.new(a: 'value', b: 2)  }

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

    it 'should raise an exception if the request fails' do
      stub_request(:get, 'http://host/test_rest_resources/b').
         to_return(:status => 500)

      lambda { TestRestResource.find('b') }.should raise_error(Shutl::RemoteError)
    end

    it 'should add a id based on the resource id' do
      resource = TestRestResource.find('a')

      resource.instance_variable_get('@id').should == 'value'
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

    it 'should raise an error of the request fails' do
      stub_request(:get, 'http://host/test_rest_resources').
         to_return(:status => 403)

      lambda { TestRestResource.all}.should raise_error(Shutl::RemoteError)

    end
  end

  describe '#create' do
    it 'should send a post request to the endpoint' do
      request = stub_request(:post, 'http://host/test_rest_resources')

      resource.create

      request.should have_been_requested
    end

    it 'should return true when the post succeeds' do
      request = stub_request(:post, 'http://host/test_rest_resources').
        to_return(:status => 200)

      resource.create.should eq(true)
    end

    it 'should return true if the remote server returns an error' do
      request = stub_request(:post, 'http://host/test_rest_resources').
         to_return(:status => 403, :body => '', :headers => {})

      resource.create.should eq(false)

      request.should have_been_requested
    end
    
    it 'should post in the body the json serialized resource' do
      resource.stub(:to_json).and_return('JSON')
      request = stub_request(:post, 'http://host/test_rest_resources').
        with( :body => 'JSON')

      resource.create

      request.should have_been_requested
    end

    it 'should post the header content-type: json' do
      request = stub_request(:post, 'http://host/test_rest_resources').
        with( :headers => { 'Content-Type' => 'application/json' } )

      resource.create

      request.should have_been_requested
    end

    it 'should raise an exception if the create is called with the ! and it fails' do
      request = stub_request(:post, 'http://host/test_rest_resources').
        to_return(:status => 400)

      lambda { resource.create! }.should raise_error(Shutl::RemoteError)
    end
  end

  describe '#delete' do

    it 'should send a delete query to the endpoint' do
      request = stub_request(:delete, 'http://host/test_rest_resources/value')

      resource.delete

      request.should have_been_requested
    end

    it 'should return true if the request succeeds' do
      stub_request(:delete, 'http://host/test_rest_resources/value').
         to_return(status: 204)

      resource.delete.should eq(true)
    end

    it 'should return false if the request fails' do
      stub_request(:delete, 'http://host/test_rest_resources/value').
         to_return(status: 400)

      resource.delete.should eq(false)
    end
  end

  describe '#save' do
    it 'should send a delete query to the endpoint' do
      request = stub_request(:put, 'http://host/test_rest_resources/value')

      resource.save

      request.should have_been_requested
    end

    it 'should return true if the request succeeds' do
      stub_request(:put, 'http://host/test_rest_resources/value').
         to_return(status: 204)

      resource.save.should eq(true)
    end

    it 'should return false if the request fails' do
      stub_request(:put, 'http://host/test_rest_resources/value').
         to_return(status: 400)

      resource.save.should eq(false)
    end

    it 'should post in the body the json serialized resource' do
      resource.stub(:to_json).and_return('JSON')
      request = stub_request(:put, 'http://host/test_rest_resources/value').
                        with(:body => 'JSON')

      resource.save

      request.should have_been_requested
    end


    it 'should raise an error if the update is called with the ! and it fails' do
      stub_request(:put, 'http://host/test_rest_resources/value').
         to_return(status: 400)

      lambda { resource.save! }.should raise_error(Shutl::RemoteError)
    end
  end

end
