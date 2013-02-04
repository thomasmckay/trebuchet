# -*- encoding: utf-8 -*-
require File.expand_path('../lib/trebuchet/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Justin Sherrill, Eric D Helms"]
  gem.email         = ["jsherril@redhat.com, ehelms@redhat.com"]
  gem.description   = ""
  gem.summary       = ""
  gem.homepage      = "https://github.com/Katello/trebuchet"

  gem.files         = Dir['lib/**/*.rb']
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test)/})
  gem.name          = "trebuchet"
  gem.require_paths = ["lib"]
  gem.version       = Trebuchet::VERSION
end
