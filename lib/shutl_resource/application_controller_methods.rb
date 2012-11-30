module ShutlResource::ApplicationControllerMethods
  def token
    session[:token]
  end

  def set_access_token
    session[:token] = Rails.cache.fetch :access_token, expires_in: 5.minutes do
      AccessTokenRequest.new.access_token
    end
  end
end


