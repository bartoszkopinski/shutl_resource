# -*- encoding: utf-8 -*-
require File.expand_path('../lib/shutl/resource/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["David Rouchy"]
  gem.email         = ["davidr@shutl.co.uk"]
  gem.description   = %q{Shutl Rest resource}
  gem.summary       = %q{Manage Shutl Rest resource. Parse/Serialize JSON}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "shutl_resource"
  gem.require_paths = ["lib"]
  gem.version       = Shutl::Resource::VERSION

  gem.add_dependency 'httparty', '~> 0.8.3'
  gem.add_dependency 'shutl_auth'
  gem.add_dependency 'activemodel'

  gem.add_development_dependency 'rspec', '~> 2.11.0'
  gem.add_development_dependency 'debugger'
  gem.add_development_dependency 'webmock', '~> 1.8.7'
end
