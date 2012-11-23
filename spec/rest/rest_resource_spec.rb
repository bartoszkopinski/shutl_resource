require 'spec_helper'

describe ShutlResource::RestResource do
  let(:headers) do
    {'Accept'=>'application/json', 'Authorization'=>'Bearer', 'Content-Type'=>'application/json'}
  end

  it 'should include the REST verb' do
    TestRestResource.should respond_to :get
    TestRestResource.should respond_to :post
    TestRestResource.should respond_to :post
    TestRestResource.should respond_to :delete
  end

  let(:resource) { TestRestResource.new(a: 'a', b: 2)  }

  describe '#find' do
    context 'with no arguments' do
      before do
        @request = stub_request(:get, 'http://host/test_rest_resources/a').
          to_return(:status => 200,
                    :body => '{"test_rest_resource": { "a": "a", "b": 2 }}',
                    :headers => headers)
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

        resource.instance_variable_get('@a').should == 'a'
        resource.instance_variable_get('@b').should == 2
      end

      {
        400 => ShutlResource::BadRequest,
        401 => ShutlResource::UnauthorizedAccess,
        403 => ShutlResource::ForbiddenAccess,
        404 => ShutlResource::ResourceNotFound,
        409 => ShutlResource::ResourceConflict,
        410 => ShutlResource::ResourceGone,
        422 => ShutlResource::ResourceInvalid,
        503 => ShutlResource::ServiceUnavailable,
        501..502 => ShutlResource::ServerError,
        504..599 => ShutlResource::ServerError
      }.each do |status, exception|
        it "raises an #{exception} exception with a #{status}" do
          if status.is_a? Range
            status.each do |s|
              stub_request(:get, 'http://host/test_rest_resources/b').
                to_return(status: s.to_i)

              expect(->{TestRestResource.find('b')}).to raise_error(exception)
            end
          else
            stub_request(:get, 'http://host/test_rest_resources/b').
              to_return(status: status)
            lambda { TestRestResource.find('b') }.should raise_error(exception)

          end

        end
      end

      it 'should add a id based on the resource id' do
        resource = TestRestResource.find('a')

        resource.instance_variable_get('@id').should == 'a'
      end
    end

    it 'should encode the url to support spaces' do
      request = stub_request(:get, 'http://host/test_rest_resources/new%20resource').
        to_return(:status => 200, :body => '{"test_rest_resource": {}}', :headers => {})

      TestRestResource.find('new resource')

      request.should have_been_requested
    end

    context 'with url arguments' do
      before do
        @request = stub_request(:get, 'http://host/test_rest_resources/a?arg1=val1&arg2=val2').
          to_return(:status => 200, :body => '{"test_rest_resource": { "a": "a", "b": 2 }}', :headers => headers)
      end

      it 'should query the endpoint with the parameters' do
        TestRestResource.find('a', arg1: 'val1', arg2: 'val2')

        @request.should have_been_requested
      end

    end
  end

  describe '#all' do

    context 'with no arguments' do
      before do
        @request = stub_request(:get, 'http://host/test_rest_resources').
          to_return(:status => 200, :body => '{"test_rest_resources": [{ "a": "a", "b": 2 }]}', :headers => headers)
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

        resource.first.instance_variable_get('@a').should == 'a'
        resource.first.instance_variable_get('@b').should == 2
      end

      it 'should raise an error of the request fails' do
        stub_request(:get, 'http://host/test_rest_resources').
          to_return(:status => 403)

        lambda { TestRestResource.all}.should raise_error(ShutlResource::ForbiddenAccess)

      end
    end

    context 'with no arguments' do
      before do
        @request = stub_request(:get, 'http://host/test_rest_resources?arg1=val1&arg2=val2').
          to_return(:status => 200, :body => '{"test_rest_resources": [{ "a": "a", "b": 2 }]}', :headers => headers)
      end

      it 'should query the endpoint' do
        TestRestResource.all(arg1: 'val1', arg2: 'val2')

        @request.should have_been_requested
      end
    end
  end

  describe '#create' do
    it 'should send a post request to the endpoint' do
      request = stub_post 200

      TestRestResource.create

      request.should have_been_requested
    end

    def stub_post status
      stub_request(:post, 'http://host/test_rest_resources').
        to_return(:status => status, :body => '', :headers => headers)
    end

    it 'should raise error if the remote server returns an error' do
      request = stub_post 403
      expect(->{TestRestResource.create}).to raise_error ShutlResource::ForbiddenAccess

      request.should have_been_requested
    end


    it 'should post the header content-type: json' do
      request = stub_request(:post, 'http://host/test_rest_resources').
        with( :headers => headers )

      TestRestResource.create

      request.should have_been_requested
    end

    it 'should raise an exception if the create is called with the ! and it fails' do
      request = stub_request(:post, 'http://host/test_rest_resources').
        to_return(:status => 400)

      expect(->{ TestRestResource.create}).to raise_error(ShutlResource::BadRequest)
    end


    it 'shoud create a new ressource with the attributes' do
      request = stub_request(:post, "http://host/test_rest_resources").
        with(body: '{"test_rest_resource":{"a":"a","b":"b"}}',
             headers: headers)

      TestRestResource.create(a: 'a', b: 'b')

      request.should have_been_requested
    end

  end

  describe '#destroy' do

    it 'should send a delete query to the endpoint' do
      request = stub_request(:delete, 'http://host/test_rest_resources/a')

      TestRestResource.destroy id: 'a'

      request.should have_been_requested
    end

    it 'should return true if the request succeeds' do
      stub_request(:delete, 'http://host/test_rest_resources/a').
        to_return(status: 204)

      TestRestResource.destroy(id: 'a').should eq(true)
    end

    it 'should return false if the request fails' do
      stub_request(:delete, 'http://host/test_rest_resources/a').
        to_return(status: 400)

      expect(->{TestRestResource.destroy(id: 'a')}).to raise_error ShutlResource::BadRequest
    end
  end

  describe '#save' do
    it 'should send a delete query to the endpoint' do
      request = stub_request(:put, 'http://host/test_rest_resources/a')

      resource.save

      request.should have_been_requested
    end

    it 'should return true if the request succeeds' do
      stub_request(:put, 'http://host/test_rest_resources/a').
        to_return(status: 204)

      resource.save.should eq(true)
    end

    it 'should return false if the request fails' do
      stub_request(:put, 'http://host/test_rest_resources/a').
        to_return(status: 400)

      ->{resource.save}.should raise_error ShutlResource::BadRequest
    end


    it 'should post in the body the json serialized resource' do
      Hash.any_instance.stub(:to_json).and_return('JSON')
      request = stub_request(:put, 'http://host/test_rest_resources/a').
        with(:body => 'JSON', headers: headers)

      resource.save

      request.should have_been_requested
    end


    it 'should raise an error if the update is called with the ! and it fails' do
      stub_request(:put, 'http://host/test_rest_resources/a').
        to_return(status: 400)

      expect(->{ resource.save }).to raise_error(ShutlResource::BadRequest)
    end
  end

  describe '#update!' do
    it 'should post the new json representation' do
      request = stub_request(:put, "http://host/test_rest_resources/a").
        with(:body => '{"test_rest_resource":{"a":"a","b":"b","id":"a"}}')
      test_resource = TestRestResource.new

      test_resource.update!(a: 'a', b: 'b')

      request.should have_been_requested
    end
  end

end
