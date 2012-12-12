module Shutl::Resource
  class AccessTokenRequest
    def initialize
      @client = Rack::OAuth2::Client.new(
        identifier: Shutl.authentication_service[:client_id],
        secret:     Shutl.authentication_service[:client_secret],
        host:       uri.host,
        port:       uri.port,
        scheme:     uri.scheme
      )
    end

    def access_token!
      Shutl.retry_connection "Authentication Service Error" do
        @client.access_token!
      end
    end

    private

    def uri
      @uri ||= URI Shutl.authentication_service[:url]
    end
  end
end
