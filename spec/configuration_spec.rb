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

    it "allows for configuration of the base uri" do
      Shutl::Resource.configure do |config|
        config.base_uri = 'base uri'
      end

      Shutl::Resource.base_uri.should == 'base uri'

      #set it back to not corrupt other tests
      Shutl::Resource.configure do |config|
        config.base_uri = nil
      end
    end
  end
end
