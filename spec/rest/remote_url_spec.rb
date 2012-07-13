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
end
