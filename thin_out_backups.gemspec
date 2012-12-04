# -*- encoding: utf-8 -*-
require File.expand_path('../lib/thin_out_backups/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Tyler Rick"]
  gem.email         = ["github.com@tylerrick.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "thin_out_backups"
  gem.require_paths = ["lib"]
  gem.version       = ThinOutBackups::Version

  gem.add_dependency 'facets'
  gem.add_dependency 'colored'
  gem.add_dependency 'quality_extensions'

  gem.add_development_dependency 'rspec'
end
