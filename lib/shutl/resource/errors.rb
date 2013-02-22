class Shutl::Resource::Error < ::IOError
  attr_reader :response

  def initialize message, http_response
    @response = http_response

    super message #it really is rather spot on, why thanks for saying, kind sir.
  end
end

# This NoQuotesGenerated is shutl specific corresponding to HTTP status 299.
# The correct solution to this would be to remove this exception from the gem
# and handle specifically in a QuoteCollection resource in for example the
# 'shutl' gem.
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


