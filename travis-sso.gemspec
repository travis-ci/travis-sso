# frozen_string_literal: true
$LOAD_PATH.unshift File.expand_path('lib', __dir__)

require 'travis/sso/version'
require 'English'
Gem::Specification.new do |gem|
  gem.name          = 'travis-sso'
  gem.version       = TravisSso::VERSION
  gem.authors       = ['Konstantin Haase']
  gem.email         = ['konstantin.mailinglists@googlemail.com']
  gem.description   = 'Travis CI Singe Sign-On as a Rack middleware'
  gem.summary       = 'Travis CI Singe Sign-On as a Rack middleware'
  gem.homepage      = 'https://github.com/travis-ci/travis-sso'

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
  gem.required_ruby_version = '>= 3.2'

  gem.add_dependency 'multi_json'
  gem.add_dependency 'rack'
  gem.add_dependency 'rotp'
  gem.add_dependency 'rqrcode'
  gem.add_dependency 'yubikey'
end
