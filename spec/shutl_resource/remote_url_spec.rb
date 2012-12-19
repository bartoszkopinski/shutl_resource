require 'spec_helper'

describe Shutl::Resource::Rest do

  class OverrideUrlResource
    include Shutl::Resource::Rest
    collection_url '/api/resources'
    resource_url '/api/resources/:name'
  end

  describe '#remote_collection_url' do
    it 'should be based on the resource name by default' do
      TestRest.remote_collection_url.should == '/test_rests'
    end

    it 'should use the override if defined' do
      OverrideUrlResource.remote_collection_url.should == '/api/resources'
    end
  end

  describe '#remote_resource_url' do
    it 'should be base on the resource name and the resource id name by default' do
      TestRest.remote_resource_url.should == '/test_rests/:a'
    end

    it 'should use the override if defined' do
      OverrideUrlResource.remote_resource_url.should == '/api/resources/:name'
    end
  end

  context 'nested resource' do
    class NestedResource
      include Shutl::Resource::Rest
      base_uri 'http://host'
      collection_url '/nested/:parent_id/resources'
      resource_url '/nested/:parent_id/resources/:id'
    end

    let(:resource) { NestedResource.new(id: 2, parent_id: 10) }

    describe '#all' do
      it 'should query the correct endpoint' do
        request = stub_request(:get, 'http://host/nested/10/resources').
          to_return(body: '{"nested_resources": []}',
                    headers: {"Content-Type" => "application/json"}
                   )

        NestedResource.all(parent_id: 10, auth: 'TOKEN')

        request.should have_been_requested
      end

      it 'should add the nested params to the attributes' do
        stub_request(:get, 'http://host/nested/10/resources').
          to_return(body: '{"nested_resources": [{}, {}]}',
                    headers: {"Content-Type" => "application/json"})

        resources = NestedResource.all(parent_id: 10, auth: 'TOKEN')

        resources.each { |r| r.parent_id.should == 10 }
      end

      it 'should support the params' do
        request = stub_request(:get, 'http://host/nested/10/resources?arg1=val1&arg2=val2').
          to_return(body: '{"nested_resources": []}',
                    headers: {"Content-Type" => "application/json"})

        NestedResource.all(parent_id: 10, arg1: 'val1', arg2: 'val2', auth: 'TOKEN')

        request.should have_been_requested
      end
    end

    describe '#find' do
      it 'should query the correct endpoint' do
        request = stub_request(:get, 'http://host/nested/10/resources/2').
          to_return(body: '{"nested_resource": {}}',
                    headers: {"Content-Type" => "application/json"})

        NestedResource.find(id: 2, parent_id: 10, auth: 'TOKEN')

        request.should have_been_requested
      end

      it 'should add the nested params to the attributes' do
        stub_request(:get, 'http://host/nested/10/resources/2').
          to_return(body: '{"nested_resource": {}}',
                    headers: {"Content-Type" => "application/json"})

        resource = NestedResource.find(id: 2, parent_id: 10, auth: 'TOKEN')

        resource.parent_id.should == 10
      end
    end

    describe 'update' do
      it 'should query the correct endpoint' do
        request = stub_request(:put, 'http://host/nested/10/resources/2').
          to_return(body: '{"nested_resource": {}}',
                    headers: {"Content-Type" => "application/json"})

        resource.save auth: 'TOKEN'

        request.should have_been_requested
      end
    end

    describe '.create' do
      it 'should query the correct endpoint' do
        request =
          stub_request(:post, 'http://host/nested/10/resources').

          with(body: '{"nested_resource":{"some_attribute":"1"}}',
               headers: {"Accept" => "application/json"}).

          to_return(body: '{"nested_resource": {}}',
                    headers: {"Content-Type" => "application/json"})

        NestedResource.create({parent_id: 10, some_attribute: "1"}, {auth: 'TOKEN'})

        request.should have_been_requested
      end
    end

    describe '#delete' do
      it 'should query the correct endpoint' do
        request = stub_request(:delete, 'http://host/nested/10/resources/2').
          to_return(body: '{"nested_resource": {}}',
                    headers: {"Content-Type" => "application/json"})

        resource.destroy auth: 'TOKEN'

        request.should have_been_requested
      end

    end
  end
end
