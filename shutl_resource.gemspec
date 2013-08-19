# -*- encoding: utf-8 -*-
require File.expand_path('../lib/shutl/resource/version', __FILE__)

$platform ||= RUBY_PLATFORM[/java/] || 'ruby'

Gem::Specification.new do |gem|
  gem.authors       = ["David Rouchy", "Volker Pacher", "Mark Burns"]
  gem.email         = ["davidr@shutl.co.uk", "volker@shutl.com", "mark@shutl.com"]
  gem.description   = %q{Shutl Rest resource}
  gem.summary       = %q{Manage Shutl Rest resource. Parse/Serialize JSON}
  gem.homepage      = ""
  gem.platform       = $platform

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "shutl_resource"
  gem.require_paths = ["lib"]
  gem.version       = Shutl::Resource::VERSION

  gem.add_dependency 'httparty', '~> 0.10.0'
  gem.add_dependency 'shutl_auth', '0.8.0'
  gem.add_dependency 'activemodel'
  gem.add_dependency 'faraday'
  gem.add_dependency 'faraday_middleware'
  gem.add_dependency 'faraday-conductivity'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec', '~> 2.11.0'
  gem.add_development_dependency 'debugger'   if $platform.to_s == 'ruby'
  gem.add_development_dependency 'ruby-debug' if $platform.to_s == 'java'

  gem.add_development_dependency 'webmock', '~> 1.8.7'
end
