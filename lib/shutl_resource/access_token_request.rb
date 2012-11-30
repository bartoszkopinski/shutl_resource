class AccessTokenRequest
  attr_reader :access_token

  def initialize
    client = Rack::OAuth2::Client.new(
      identifier: Shutl.client_id,
      secret:     Shutl.client_secret,
      host:       uri.host,
      port:       uri.port,
      scheme:     uri.scheme
    )

    @access_token = Shutl.retry_connection "Authentication Service Error" do
      client.access_token!.access_token
    end
  end

  private

  def uri
    @uri ||= URI Shutl.authentication_service_url
  end
end
