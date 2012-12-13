require 'spec_helper'

describe Shutl::Resource::Rest do
  class TestResource
    include Shutl::Resource::Rest
    base_uri 'host'
  end

  class TestOverride
    include Shutl::Resource::Rest
    resource_name 'a_other_prefix'
  end

  let(:token) { 'TEST_BEARER_TOKEN' }

  let(:headers) do
    {
      "Accept"        => "application/json",
      "Content-Type"  => "application/json",
      "Authorization" => "Bearer #{token}"
    }
  end

  describe '#initialize' do
    let(:resource) { TestResource.new({ a: 'a', b: 'b' }) }

    specify { resource.instance_variables.should =~ [ :@a, :@b, :@response] }

    it 'should assign the instance variable value for the entries in the hash' do
      resource.instance_variable_get(:@a).should == 'a'
      resource.instance_variable_get(:@b).should == 'b'
    end

    it 'should create a attribute reader' do
      resource.a().should == 'a'
    end

    it 'should keep the method not found behaviour' do
      lambda { resource.notfound() }.should raise_error(NameError)
    end
  end

  describe '#to_json' do
    let(:resource) { TestResource.new({ a: 'a', b: 'b' }) }

    it 'should "prefix" the json with the name of the class' do
      json = resource.to_json

      JSON.parse(json, symbolize_names: true)[:test_resource].should_not be_nil
    end

    it 'should serialize in json based on the instance variables' do
      json = resource.to_json

      JSON.parse(json, symbolize_names: true).should == { test_resource: { a: 'a', b: 'b' } }
    end

    it 'should be able to overribe the prefix' do
      json = TestOverride.new({ a: 'a'}).to_json

      JSON.parse(json, symbolize_names: true)[:a_other_prefix].should_not be_empty
    end
  end

  describe '#update' do
    it 'should put the new json representation' do
      stub_request(:post, "/host/test_resources").
        with(headers: headers).
        to_return(body: '{"test_resource":{"a":"a","b":"b","id":"1"}}',
                  headers: { 'Content-Type' => 'application/json' } )

      test_resource = TestResource.create({}, {auth: token})

      request = stub_request(:put, "/host/test_resources/1").
        with(:body => '{"test_resource":{"a":"1","b":"2","id":"1"}}').
        with(headers: headers)

      TestResource.update({a: '1', b: '2', id: '1'}, {auth: token})

      request.should have_been_requested
    end
  end

  describe 'udpate_attributes!' do
    let(:resource) { TestResource.new({ a: 'a', b: 'b' }) }

    it 'should replace the attributes' do
      resource.update_attributes(a: 'c')

      resource.instance_variable_get(:@a).should == 'c'
    end

    it 'should use a white list permission'

  end

  it 'should include the REST verb' do
    TestResource.should respond_to :get
    TestResource.should respond_to :post
    TestResource.should respond_to :post
    TestResource.should respond_to :delete
  end


  describe '#find' do
    context 'with no arguments' do
      before do
        @request = stub_request(:get, "/host/test_resources/a").
          with(headers: headers).
          to_return(:status => 200, :body => '{"test_resource":{"a": "value", "b": 2}}',
                    :headers => {"Content-Type" => "application/json"})
      end

      let(:resource) { TestResource.find('a', {auth: token}) }

      it 'should query the endpoint' do
        resource
        @request.should have_been_requested
      end

      specify { resource.should be_kind_of TestResource }

      it 'should add a id based on the resource id' do
        resource.instance_variable_get('@id').should == 'a'
      end

      it 'should assign the attributes based on the json returned' do
        resource.instance_variable_get('@a').should == 'value'
        resource.instance_variable_get('@b').should == 2
      end

      {
        400 => Shutl::BadRequest,
        401 => Shutl::UnauthorizedAccess,
        403 => Shutl::ForbiddenAccess,
        404 => Shutl::ResourceNotFound,
        409 => Shutl::ResourceConflict,
        410 => Shutl::ResourceGone,
        500 => Shutl::ServerError,
        503 => Shutl::ServiceUnavailable
      }.each do |status, exception|
        it "should raise an #{exception} if the response is a #{status}" do
          stub_request(:get, "/host/test_resources/b").
            with(headers: headers).
            to_return(:status => status)
          quote_service_response = mock(
            'response',
            content_type: 'application/json',
            body: "{error:['error']}",
            code: status)

          lambda { TestResource.find('b', {auth: token}) }.should raise_error(exception)
        end
      end


    end

    it 'should encode the url to support spaces' do
      request = stub_request(:get, "/host/test_resources/new%20resource").
        with(headers: headers).
        to_return(:status => 200, :body => '{"test_resource": {}}',
                    :headers => { 'Content-Type' => 'application/json' } )

      TestResource.find('new resource', {auth: token})

      request.should have_been_requested
    end

    context 'with url arguments' do
      before do
        @request = stub_request(:get, "/host/test_resources/a?arg1=val1&arg2=val2").
          with(headers: headers).
          to_return(:status => 200, :body => '{"test_resource": { "a": "value", "b": 2 }}',
                    :headers => { 'Content-Type' => 'application/json' } )
      end

      it 'should query the endpoint with the parameters' do
        TestResource.find 'a', arg1: 'val1', arg2: 'val2', auth: token

        @request.should have_been_requested
      end

    end
  end

  describe '#all' do
    context 'with no arguments' do
      before do
        @request = stub_request(:get, "/host/test_resources").
          to_return(:status => 200,
                    :body => '{"test_resources": [{ "a": "value", "b": 2 }]}',
                    :headers => headers )
      end

      it 'should query the endpoint' do
        TestResource.all auth: token

        @request.should have_been_requested
      end

      it 'should parse the result of the body to create an array' do
        resource = TestResource.all auth: token

        resource.should have(1).item
      end

      it 'should assign the attributes based on the json returned' do
        resource = TestResource.all auth: token

        resource.first.instance_variable_get('@a').should == 'value'
        resource.first.instance_variable_get('@b').should == 2
      end
    end

    context 'with no arguments' do
      before do
        @request = stub_request(:get, "/host/test_resources?arg1=val1&arg2=val2").
          to_return(:status => 200, :body => '{"test_resources": [{ "a": "value", "b": 2 }]}',
                    :headers => headers )
      end

      it 'should query the endpoint' do
        TestResource.all(arg1: 'val1', arg2: 'val2', auth: token)

        @request.should have_been_requested
      end
    end
  end

  describe '#create' do
    it 'should raise an exception if the remote server returns an error' do
      request =
        stub_request(:post, "/host/test_resources/").
        with(headers: headers).
        to_return status: 403,
                  body: '',
                  headers: { 'Content-Type' => 'application/json' }

      ->{ TestResource.create}.should raise_error
    end

    it 'should create a new resource with the attributes' do
      request =
        stub_request(:post, "/host/test_resources").
        with(:headers => headers,
             :body => '{"test_resource":{"a":"a","b":"b"}}').
        to_return status: 403,
                  body: '{"test_resource":{"a":"a","id":"id","b":"b"}}',
                  headers: { 'Content-Type' => 'application/json' }


      lambda do
        TestResource.create({a: 'a', b: 'b'}, {auth: token})
      end.should raise_error Shutl::ForbiddenAccess

      request.should have_been_requested
    end
  end

  describe '.destroy' do
    it 'should send a delete query to the endpoint' do
      request = stub_request(:delete, "/host/test_resources/value").
        with(headers: headers)

      TestResource.destroy({id: 'value'}, {auth: token})

      request.should have_been_requested
    end

    it 'should return true if the request succeeds' do
      stub_request(:delete, "/host/test_resources/value").
        to_return(status: 204,
                    :headers => { 'Content-Type' => 'application/json' } )

      TestResource.destroy({id: 'value'}, {auth: token}).should eq(true)
    end
  end

  describe '#save' do
    let(:resource) { TestResource.new({id: 'value', b: '2' }) }

    it 'should send a save query to the endpoint' do
      request = stub_request(:put, "/host/test_resources/value")

      resource.save auth: token

      request.should have_been_requested
    end

    it 'should return true if the request succeeds' do
      stub_request(:put, "/host/test_resources/value").
        to_return(status: 204,
                    :headers => { 'Content-Type' => 'application/json' } )

      resource.save(auth: token).should eq(true)
    end

    it 'should raise an exception if the request fails' do
      stub_request(:put, "/host/test_resources/value").
        to_return(status: 400,
                    :headers => { 'Content-Type' => 'application/json' } )

      ->{ resource.save(auth: token) }.should raise_error Shutl::BadRequest
    end
  end
end
