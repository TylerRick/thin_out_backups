# -*- encoding: utf-8 -*-
require File.expand_path('../lib/thin_out_backups/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Tyler Rick"]
  gem.email         = ["github.com@tylerrick.com"]
  gem.summary       = %q{Thin out a directory full of backups, only keeping a specified number from each category (weekly, daily, etc.), and deleting the rest.}
  gem.description   = gem.summary
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "thin_out_backups"
  gem.require_paths = ["lib"]
  gem.version       = ThinOutBackups::Version

  gem.add_dependency 'facets'
  gem.add_dependency 'rainbow'
  gem.add_dependency 'activesupport'

  gem.add_development_dependency 'rspec'
end
