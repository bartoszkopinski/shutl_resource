require 'spec_helper'

describe HTTParty::Request do

  let(:logger) { double('logger').as_null_object  }

  before do
    Shutl::Rest.logger = logger

    @request = stub_request(:get, "http://host/test_rest_resources").
                  to_return(:status => 200, :body => '{ "test_rest_resources": []}', :headers => {})
  end

  describe '#perform' do

    it 'should still perform the request' do
      TestRestResource.all

      @request.should have_been_requested
    end

    it 'should log the request' do
      logger.should_receive(:info).with('GET http://host:80/test_rest_resources')

      TestRestResource.all
    end

    it 'should log the response' do
      logger.should_receive(:info).with('--> 200  28 (0.0ms)')

      TestRestResource.all
    end
  end
end
