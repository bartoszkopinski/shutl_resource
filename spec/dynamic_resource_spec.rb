require 'spec_helper'

describe Shutl::Resource::Rest do

  class TestResource
    include Shutl::Resource::Rest
  end

  class TestOverride
    include Shutl::Resource::Rest
    resource_name 'a_other_prefix'
  end

  let(:resource) { TestResource.new({ a: 'a', b: 'b' }) }

  describe '#initalize' do
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

  describe 'udpate_attributes' do

    it 'should replace the attributes' do
      resource.update_attributes(a: 'c')

      resource.instance_variable_get(:@a).should == 'c'

    end
  end
end
