require 'spec_helper'

describe Shutl::Rest do

  describe '#configure' do
    let(:logger) { Shutl::Rest.logger }

    it 'should configure the logger' do
      logger = stub('logger')

      Shutl::Rest.configure do |config|
        config.logger = logger
      end

      Shutl::Rest.logger.should == logger
    end
  end
end