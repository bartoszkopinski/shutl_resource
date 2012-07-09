require_relative '../lib/shutl_resource/dynamic_resource'

describe Shutl::DynamicResource do

  class TestResource
    include Shutl::DynamicResource
  end

  describe '#initalize' do

    it 'should create a instance variable for the entries in the hash' do
      resource = TestResource.new({ a: 'a', b: 'b' })

      resource.instance_variables.should =~ [ :@a, :@b ]
    end

    it 'should assign the instance variable value for the entries in the hash' do
      resource = TestResource.new( { a: 'a', b: 'b' })

      resource.instance_variable_get(:@a).should == 'a'
      resource.instance_variable_get(:@b).should == 'b'
    end
  end
end
