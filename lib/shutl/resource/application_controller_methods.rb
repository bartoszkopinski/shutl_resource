module Shutl::Resource::ApplicationControllerMethods
  def request_access_token
    return if session[:access_token]

    access_token_response = AccessTokenRequest.new.access_token!
    session[:access_token] = access_token_response.access_token
  end

  def access_token
    session[:access_token]
  end

  def authenticated_request &blk
    begin
      yield
    rescue Shutl::UnauthorizedAccess => e
      session[:access_token] = nil
      request_access_token
      yield
    end
  end
end
