# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'atdis/version'

Gem::Specification.new do |spec|
  spec.name          = "atdis"
  spec.version       = Atdis::VERSION
  spec.authors       = ["Matthew Landauer"]
  spec.email         = ["matthew@openaustraliafoundation.org.au"]
  spec.description   = %q{A ruby interface to the application tracking data interchange specification (ATDIS) API}
  spec.summary       = spec.description
  spec.homepage      = "http://github.com/openaustralia/atdis"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency "multi_json", "~> 1.7"
  spec.add_dependency "rest-client"
  spec.add_dependency "rgeo-geojson"
  spec.add_dependency "activemodel", "~> 3"
end
