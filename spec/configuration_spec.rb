require 'spec_helper'

describe Shutl::Resource do
  describe '#configure' do
    let(:logger) { Shutl::Resource.logger }

    it 'should configure the logger' do
      logger = stub('logger')

      Shutl::Resource.configure do |config|
        config.logger = logger
      end

      Shutl::Resource.logger.should == logger
    end
  end
end
