require 'spec_helper'

describe Shutl::Resource do
  after do
    Shutl::Resource.configure do |config|
      config.base_uri  = nil
      config.proxy_uri = nil
    end
  end

  describe '#configure' do
    it "allows for configuration of the base uri" do
      Shutl::Resource.configure do |config|
        config.base_uri = 'base uri'
      end

      Shutl::Resource.base_uri.should == 'base uri'
    end

    it "allows for configuration of the proxy uri" do
      Shutl::Resource.configure do |config|
        config.proxy_uri = 'proxy uri'
      end

      Shutl::Resource.proxy_uri.should == 'proxy uri'
    end
  end
end
