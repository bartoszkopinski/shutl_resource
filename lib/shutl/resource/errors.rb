class Shutl::Resource::Error < ::IOError
  attr_reader :response

  def initialize message, http_response
    @response = http_response

    super message #it really is rather spot on, why thanks for saying, kind sir.
  end
end

# This NoQuotesGenerated is shutl specific corresponding to HTTP status 299.
# We had a good think about what the correct HTTP code is for the case that
# the request is fine, but we couldn't generate any quotes. It doesn't feel
# like a 4xx or a 5xx, but not quite like a 2xx either. Comments/thoughts
# more than welcome.
Shutl::NoQuotesGenerated  = Class.new Shutl::Resource::Error

Shutl::BadRequest         = Class.new Shutl::Resource::Error
Shutl::UnauthorizedAccess = Class.new Shutl::Resource::Error
Shutl::ForbiddenAccess    = Class.new Shutl::Resource::Error
Shutl::ResourceNotFound   = Class.new Shutl::Resource::Error
Shutl::ResourceConflict   = Class.new Shutl::Resource::Error
Shutl::ResourceGone       = Class.new Shutl::Resource::Error
Shutl::ResourceInvalid    = Class.new Shutl::Resource::Error
Shutl::ServerError        = Class.new Shutl::Resource::Error
Shutl::ServiceUnavailable = Class.new Shutl::Resource::Error


