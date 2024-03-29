# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "jm/version"

Gem::Specification.new do |spec|
  spec.name          = "jm"
  spec.version       = JM::VERSION
  spec.authors       = ["Marten Lienen"]
  spec.email         = ["marten.lienen@gmail.com"]
  spec.summary       = "Bidirectional JSON mapping"
  spec.description   = ""
  spec.homepage      = "https://github.com/CQQL/jm"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "addressable", "~> 2.3"
  spec.add_dependency "i18n", "~> 0.6"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake", "~> 10.3"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 0.24"
  spec.add_development_dependency "yard", "~> 0.8"
  spec.add_development_dependency "redcarpet", "~> 3.1"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "translations"
end
