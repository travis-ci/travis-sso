Gem::Specification.new do |gem|
  gem.name          = "travis-sso"
  gem.version       = "0.0.1"
  gem.authors       = ["Konstantin Haase"]
  gem.email         = ["konstantin.mailinglists@googlemail.com"]
  gem.description   = ""
  gem.summary       = ""
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'rack'
  gem.add_dependency 'multi_json'
end
