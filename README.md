# Shutl::Resource

Yep this is ActiveResource-esque.

Abstracted from our backend, but no reason to not make this public. Possibly
useful elsewhere.
Only slightly strange thing you may find is that we have our own HTTP status
code (299) which corresponds to the case of no quotes generated. The jury is
still out on this.

This NoQuotesGenerated is shutl specific corresponding to HTTP status 299.
We had a good think about what the correct HTTP code is for the case that
the request is fine, but we couldn't generate any quotes. It doesn't feel
like a 4xx or a 5xx, but not quite like a 2xx either. Comments/thoughts
more than welcome.

#Config

`config/initializers/shutl_resource.rb`

```ruby
Shutl::Resource.configure do |c|
  c.logger = Rails.logger
end
```

```ruby
class ApplicationController
  include Shutl::Resource::ApplicationControllerMethods
end
```

#Usage

```ruby
#app/resources/spider_cow.rb
class SpiderCow
  include Shutl::Resource::Rest
  base_uri "http://localhost:3001"
end

#app/controllers/spider_cows_controller.rb
class SpiderCowsController < Shutl::Resource::BackendResourcesController
end

#/app/converters/boolean_converter.rb
module BooleanConverter
  extend self

  def to_front_end b; b           end
  def to_back_end  b; b == 'true' end
end

#/app/converters/spider_cow_converter.rb
module SpiderCowConverter
  extend Shutl::Resource::Converter

  convert :enabled,
    with: BooleanConverter,
    only: :to_back_end
end

```



# OAuth2
It uses OAuth2 Bearer tokens for API calls.

e.g. the following header is attached to requests

`
Authorization: Bearer some/big/long/base64/thing/goes/here==
`

```
  200..399 no problem
  299      Shutl::NoQuotesGenerated
  400      Shutl::BadRequest
  401      Shutl::UnauthorizedAccess
  403      Shutl::ForbiddenAccess
  404      Shutl::ResourceNotFound
  409      Shutl::ResourceConflict
  410      Shutl::ResourceGone
  422      Shutl::ServerError
  500      Shutl::ServiceUnavailable
```

## Installation

Add this line to your rails app's Gemfile:

    gem 'shutl_resource'


## Contributing

The usual: fork, branch, commit, pull request
