require 'json'
require_relative '../lib/shutl_resource/dynamic_resource'

describe Shutl::DynamicResource do

  class TestResource
    include Shutl::DynamicResource
  end

  let(:resource) { TestResource.new({ a: 'a', b: 'b' }) }

  describe '#initalize' do

    it 'should create a instance variable for the entries in the hash' do
      resource.instance_variables.should =~ [ :@a, :@b ]
    end

    it 'should assign the instance variable value for the entries in the hash' do
      resource.instance_variable_get(:@a).should == 'a'
      resource.instance_variable_get(:@b).should == 'b'
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
  end
end
