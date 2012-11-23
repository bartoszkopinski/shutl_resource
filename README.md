# ShutlResource

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

# OAuth2
It uses OAuth2 Bearer tokens for API calls.

e.g. the following header is attached to requests

`
Authorization: Bearer some/big/long/base64/thing/goes/here==
`

```
  200..399 no problem
  299      ShutlResource::NoQuotesGenerated
  400      ShutlResource::BadRequest
  401      ShutlResource::UnauthorizedAccess
  403      ShutlResource::ForbiddenAccess
  404      ShutlResource::ResourceNotFound
  409      ShutlResource::ResourceConflict
  410      ShutlResource::ResourceGone
  422      ShutlResource::ServerError
  500      ShutlResource::ServiceUnavailable
```

## Installation

Add this line to your application's Gemfile:

    gem 'shutl_resource'



And then execute:

```
bundle
```

Or install it yourself as:

```
gem install shutl_resource
```


## Contributing

The usual: fork, branch, commit, pull request
