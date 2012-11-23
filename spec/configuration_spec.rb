require 'spec_helper'

describe ShutlResource do
  describe '#configure' do
    let(:logger) { ShutlResource.logger }

    it 'should configure the logger' do
      logger = stub('logger')

      ShutlResource.configure do |config|
        config.logger = logger
      end

      ShutlResource.logger.should == logger
    end
  end
end
