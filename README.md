# Shutl::Resource

[![Build Status](https://travis-ci.org/shutl/shutl_resource.png?branch=master)](https://travis-ci.org/shutl/shutl_resource)

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

#Usage

```ruby
#app/models/shutl/quote.rb
class Shutl::QuoteCollection
  include Shutl::Resource::Rest
  base_uri "http://shutl-api-url"
end
```


The following exceptions may be raised
```
  200..399 no problem
  299      Shutl::NoQuotesGenerated
  400      Shutl::BadRequest
  401      Shutl::UnauthorizedAccess
  403      Shutl::ForbiddenAccess
  404      Shutl::ResourceNotFound
  409      Shutl::ResourceConflict
  410      Shutl::ResourceGone
  422      Shutl::ResourceInvalid
  500      Shutl::ServiceUnavailable
```

## Installation

Add this line to your rails app's Gemfile:

    gem 'shutl_resource'

# OAuth2
It uses OAuth2 Bearer tokens for API calls using the shutl_auth gem

e.g. the following header is attached to requests

`
Authorization: Bearer some-big-long-urlsafe-base64-thing-goes-here
`



## Contributing

The usual: fork, branch, commit, pull request
