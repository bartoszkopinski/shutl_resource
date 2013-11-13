require 'spec_helper'

describe Shutl::Resource::Rest do
  let(:headers) do
    { 'Accept'       => 'application/json',
      'Content-Type' => 'application/json',
      'User-Agent'   => "Shutl Resource Gem v#{Shutl::Resource::VERSION}" }
  end

  let(:resource) { TestRest.new(a: 'a', b: 2) }

  describe '#find' do
    context "with a singular resource" do
      let(:resource) { TestSingularResource.new }

      before do
        @request = stub_request(:get, 'http://host/test_singular_resource').
          to_return(:status  => 200,
                    :body    => '{"test_singular_resource": { "a": "a", "b": 2 }}',
                    :headers => headers)
      end

      it 'queries the endpoint' do
        TestSingularResource.find(auth: "some auth")
        @request.should have_been_requested
      end

      it 'should parse the result of the body to create an object' do
        resource = TestSingularResource.find(auth: "some auth")

        resource.should_not be_nil
        resource.should be_kind_of TestSingularResource
      end

      it 'should assign the attributes based on the json returned' do
        resource = TestSingularResource.find(auth: "some auth")

        resource.a.should == 'a'
        resource.b.should == 2
      end
    end

    context 'pagination' do
      let(:body) do
        {
          test_rest: { a: "a", b: 2 },
          pagination: pagination
        }.to_json
      end
      let(:pagination) { {previous_resource: 1, next_resource: 3} }

      before do
        @request = stub_request(:get, 'http://host/test_rests/a').
          to_return(status: 200, body: body, headers: headers)
      end

      context 'both present' do
        specify do
          resource = TestRest.find('a', auth: "some auth")
          resource.previous_resource.should == 1
          resource.next_resource    .should == 3
        end
      end

      context 'one present' do
        let(:pagination) { {next_resource: 3} }
        specify do
          resource = TestRest.find('a', auth: "some auth")
          resource.previous_resource.should be_nil
          resource.next_resource    .should == 3
        end
      end

      context 'none present' do
        let(:body) do
          {
            test_rest: { a: "a", b: 2 }
          }.to_json
        end
        specify do
          resource = TestRest.find('a', auth: "some auth")
          resource.pagination       .should be_nil
          resource.previous_resource.should be_nil
          resource.next_resource    .should be_nil
        end
      end
    end

    context 'with no arguments' do
      let(:headers_with_auth) do
        headers.merge("Authorization" => "Bearer some auth")
      end

      before do
        @request = stub_request(:get, 'http://host/test_rests/a').
          to_return(:status  => 200,
                    :body    => '{"test_rest": { "a": "a", "b": 2 }}',
                    :headers => headers_with_auth)
      end

      it 'should query the endpoint' do
        TestRest.find('a', auth: "some auth")

        @request.should have_been_requested
      end

      it 'should parse the result of the body to create an object' do
        resource = TestRest.find('a', auth: "some auth")

        resource.should_not be_nil
        resource.should be_kind_of TestRest
      end

      it 'should assign the attributes based on the json returned' do
        resource = TestRest.find('a', auth: "some auth")

        resource.attributes['a'].should == 'a'
        resource.attributes['b'].should == 2
      end

      context "299" do
        specify do
          @default = Shutl::Resource.raise_exceptions_on_no_quotes_generated
          Shutl::Resource.raise_exceptions_on_no_quotes_generated = false

          stub_request(:get, 'http://host/test_rests/b').
            to_return(status: 299, :body => '{"errors": {"base":["No quotes for you today"]}}')

          expect(-> { TestRest.find('b') }).not_to raise_error Shutl::NoQuotesGenerated
          Shutl::Resource.raise_exceptions_on_no_quotes_generated = @default
        end
      end

      context "422" do
        before do
          @default = Shutl::Resource.raise_exceptions_on_validation
          Shutl::Resource.raise_exceptions_on_validation = true
        end

        after do
          Shutl::Resource.raise_exceptions_on_validation = @default
        end
        specify do
          stub_request(:get, 'http://host/test_rests/b').
            to_return(status: 422)

          expect(-> { TestRest.find('b') }).to raise_error(Shutl::ResourceInvalid)
        end
      end

      {
        299      => Shutl::NoQuotesGenerated,
        400      => Shutl::BadRequest,
        401      => Shutl::UnauthorizedAccess,
        403      => Shutl::ForbiddenAccess,
        404      => Shutl::ResourceNotFound,
        409      => Shutl::ResourceConflict,
        410      => Shutl::ResourceGone,
        503      => Shutl::ServiceUnavailable,
        501..502 => Shutl::ServerError,
        504..599 => Shutl::ServerError
      }.each do |status, exception|
        it "raises an #{exception} exception with a #{status}" do
          if status.is_a? Range
            status.each do |s|
              stub_request(:get, 'http://host/test_rests/b').
                to_return(status: s.to_i)

              expect(-> { TestRest.find('b') }).to raise_error(exception)
            end
          else
            stub_request(:get, 'http://host/test_rests/b').
              to_return(status: status)
            lambda { TestRest.find('b') }.should raise_error(exception)

          end

        end
      end


      it 'should add a id based on the resource id' do
        resource = TestRest.find('a')

        resource.attributes['id'].should == 'a'
      end
    end

    it 'should encode the url to support spaces' do
      request = stub_request(:get, 'http://host/test_rests/new%20resource').
        to_return(:status  => 200, :body => '{"test_rest": {}}',
                  :headers => headers)

        TestRest.find('new resource')

        request.should have_been_requested
    end

    context 'with url arguments' do
      before do
        @request = stub_request(:get, 'http://host/test_rests/a?arg1=val1&arg2=val2').
          to_return(:status => 200, :body => '{"test_rest": { "a": "a", "b": 2 }}', :headers => headers)
      end

      it 'should query the endpoint with the parameters' do
        TestRest.find('a', arg1: 'val1', arg2: 'val2')

        @request.should have_been_requested
      end

    end
  end

  describe '#all' do

    context 'with no arguments' do
      let(:body) do
        '{
          "test_rests": [{ "a": "a", "b": 2 }],
          "pagination":{"page": 0,"items_on_page": 1,"total_count": 3, "number_of_pages": 3}
        }'
      end

      before do
        @request = stub_request(:get, 'http://host/test_rests').
          to_return(:status => 200, :body => body, :headers => headers)
      end

      it 'should query the endpoint' do
        TestRest.all

        @request.should have_been_requested
      end

      it 'should parse the result of the body to create an array' do
        resource = TestRest.all

        resource.should have(1).item
      end

      it 'should assign the attributes based on the json returned' do
        resource = TestRest.all

        resource.first.attributes['a'].should == 'a'
        resource.first.attributes['b'].should == 2
      end

      it 'should provide accessor to pagination' do
        resource = TestRest.all
        resource.pagination.page.should            == 0
        resource.pagination.items_on_page.should   == 1
        resource.pagination.total_count.should     == 3
        resource.pagination.number_of_pages.should == 3
      end

      it 'should raise an error of the request fails' do
        stub_request(:get, 'http://host/test_rests').
          to_return(:status => 403)

        lambda { TestRest.all }.should raise_error(Shutl::ForbiddenAccess)

      end

      context 'ordering the collection' do
        let(:body) do
          '{
            "test_rests": [{ "name": "D" }, {"name": "e"}, {"name": "a"}],
            "pagination":{"page": 0,"items_on_page": 1,"total_count": 3, "number_of_pages": 3}
          }'
        end

        before do
          TestRest.order_collection_by :name
        end

        after do
          TestRest.instance_variable_set(:@order_collection_by, nil)
        end

        it 're-orders the result' do
          TestRest.all.map(&:name).should == %w(a D e)
        end
      end
    end

    context 'with no arguments' do
      before do
        @request = stub_request(:get, 'http://host/test_rests?arg1=val1&arg2=val2').
          to_return(:status => 200, :body => '{"test_rests": [{ "a": "a", "b": 2 }]}', :headers => headers)
      end

      it 'should query the endpoint' do
        TestRest.all(arg1: 'val1', arg2: 'val2')

        @request.should have_been_requested
      end
    end
  end

  describe '.create' do

    context "With the setting to not raise exceptions" do
      before do
        Shutl::Resource.raise_exceptions_on_validation = false
      end

      after do
        Shutl::Resource.raise_exceptions_on_validation = true
      end

      specify do
        errors = { "base" => "invalid", "some_field" => "some field is invalid" }
        body   = { "errors" => errors }.to_json

        @request = stub_request(:post, 'http://host/test_rests').
          to_return(:status => 422, body: body, :headers => headers)

        expect { @instance = TestRest.create }.to_not raise_error Shutl::ResourceInvalid

        @request.should have_been_requested
        @instance.should_not be_valid
        @instance.errors.should == errors
      end
    end


    it 'should send a post request to the endpoint' do
      request = stub_post 200

      TestRest.create

      request.should have_been_requested
    end

    def stub_post status
      stub_request(:post, 'http://host/test_rests').
        to_return(:status => status, :body => '{}', :headers => headers)
    end

    it 'should raise error if the remote server returns an error' do
      request = stub_post 403
      expect(-> { TestRest.create }).to raise_error Shutl::ForbiddenAccess

      request.should have_been_requested
    end


    it 'should post the header content-type: json' do
      request = stub_request(:post, 'http://host/test_rests').
        with(:body => '{"test_rest":{}}', :headers => headers)

      TestRest.create

      request.should have_been_requested
    end

    it 'should raise an exception if the create is called with the ! and it fails' do
      request = stub_request(:post, 'http://host/test_rests').
        to_return(:status => 400)

      expect(-> { TestRest.create }).to raise_error(Shutl::BadRequest)
    end


    it 'shoud create a new ressource with the attributes' do
      request = stub_request(:post, "http://host/test_rests").
        with(body:    '{"test_rest":{"a":"a","b":"b"}}',
             headers: headers)

        TestRest.create(a: 'a', b: 'b')

        request.should have_been_requested
    end

  end

  describe '#destroy' do

    it 'should send a delete query to the endpoint' do
      request = stub_request(:delete, 'http://host/test_rests/a')

      TestRest.destroy id: 'a'

      request.should have_been_requested
    end

    it 'should return true if the request succeeds' do
      stub_request(:delete, 'http://host/test_rests/a').
        to_return(status: 204)

      TestRest.destroy(id: 'a').should eq(true)
    end

    it 'should return false if the request fails' do
      stub_request(:delete, 'http://host/test_rests/a').
        to_return(status: 400)

      expect(-> { TestRest.destroy(id: 'a') }).to raise_error Shutl::BadRequest
    end
  end

  describe '#save' do
    it 'should send a delete query to the endpoint' do
      request = stub_request(:put, 'http://host/test_rests/a')

      resource.save

      request.should have_been_requested
    end

    it 'should return true if the request succeeds' do
      stub_request(:put, 'http://host/test_rests/a').
        to_return(status: 204)

      resource.save.should eq(true)
    end

    it 'should return false if the request fails' do
      stub_request(:put, 'http://host/test_rests/a').
        to_return(status: 400)

      -> { resource.save }.should raise_error Shutl::BadRequest
    end


    it 'should post in the body the json serialized resource' do
      Hash.any_instance.stub(:to_json).and_return('JSON')
      request = stub_request(:put, 'http://host/test_rests/a').
        with(:body => 'JSON', headers: headers)

      resource.save

      request.should have_been_requested
    end


    it 'should raise an error if the update is called with the ! and it fails' do
      stub_request(:put, 'http://host/test_rests/a').
        to_return(status: 400)

      expect(-> { resource.save }).to raise_error(Shutl::BadRequest)
    end
  end

  describe '#update!' do
    it 'should post the new json representation' do
      request = stub_request(:put, "http://host/test_rests/a").
        with(:body    => { test_rest: { a: "a", b: "b", id: "a" } },
             :headers => { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }).
        to_return(:status => 200, :body => "", :headers => {})

      test_resource = TestRest.new

      test_resource.update!(a: 'a', b: 'b')

      request.should have_been_requested
    end

    it 'should convert new_id to id in attributes' do
      request = stub_request(:put, "http://host/test_rests/a").
        with(:body    => { test_rest: { a: "a", b: "b", id: "xxx" } },
             :headers => { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }).
        to_return(:status => 200, :body => "", :headers => {})

      test_resource = TestRest.new

      test_resource.update!(a: 'a', b: 'b', new_id: 'xxx')

      request.should have_been_requested
    end
  end

    describe '#respond_to?' do
      subject { TestRest.new a:1, b:2 }

      it 'responds to a getter if it has an attribute' do
        subject.respond_to?(:a).should be_true
      end

      it 'does not responsd to a getter if there is no attributes' do
         subject.respond_to?(:foo).should be_false
      end
    end
end
