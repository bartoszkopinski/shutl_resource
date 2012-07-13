require 'spec_helper'

describe Shutl::Rest::RestResource do

  class OverrideUrlResource
    include Shutl::Rest::RestResource
    collection_url '/api/resources'
    resource_url '/api/resources/:name'
  end

  describe '#remote_collection_url' do
    it 'should be based on the resource name by default' do
      TestRestResource.remote_collection_url.should == '/test_rest_resources'
    end

    it 'should use the override if defined' do
      OverrideUrlResource.remote_collection_url.should == '/api/resources'
    end
  end

  describe '#remote_resource_url' do
    it 'should be base on the resource name and the resource id name by default' do
      TestRestResource.remote_resource_url.should == '/test_rest_resources/:a'
    end

    it 'should use the override if defined' do
      OverrideUrlResource.remote_resource_url.should == '/api/resources/:name'
    end
  end

  context 'nested resource' do
    class NestedResource
      include Shutl::Rest::RestResource
      base_uri 'http://host'
      collection_url '/nested/:parent_id/resources'
      resource_url '/nested/:parent_id/resources/:id'
    end

    let(:resource) { NestedResource.new(id: 2, parent_id: 10) }

    describe '#all' do
      it 'should query the correct endpoint' do
        request = stub_request(:get, 'http://host/nested/10/resources').
          to_return(body: '{"nested_resources": []}')

        NestedResource.all(parent_id: 10)

        request.should have_been_requested
      end

      it 'should add the nested params to the attributes' do
        stub_request(:get, 'http://host/nested/10/resources').
          to_return(body: '{"nested_resources": [{}, {}]}')

        resources = NestedResource.all(parent_id: 10)

        resources.each { |r| r.parent_id.should == 10 }
      end
    end

    describe '#find' do
      it 'should query the correct endpoint' do
        request = stub_request(:get, 'http://host/nested/10/resources/2').
          to_return(body: '{"nested_resource": {}}')

        NestedResource.find(id: 2, parent_id: 10)

        request.should have_been_requested
      end

      it 'should add the nested params to the attributes' do
        stub_request(:get, 'http://host/nested/10/resources/2').
          to_return(body: '{"nested_resource": {}}')

        resource = NestedResource.find(id: 2, parent_id: 10)

        resource.parent_id.should == 10
      end
    end

    describe 'update' do
      it 'should query the correct endpoint' do
        request = stub_request(:put, 'http://host/nested/10/resources/2').
          to_return(body: '{"nested_resource": {}}')

        resource.save

        request.should have_been_requested
      end
    end

    describe '#create' do
      it 'should query the correct endpoint' do
        request = stub_request(:post, 'http://host/nested/10/resources').
          to_return(body: '{"nested_resource": {}}')

        resource.create

        request.should have_been_requested
      end
    end

    describe '#delete' do
      it 'should query the correct endpoint' do
        request = stub_request(:delete, 'http://host/nested/10/resources/2').
          to_return(body: '{"nested_resource": {}}')

        resource.delete

        request.should have_been_requested
      end

    end
  end
end
