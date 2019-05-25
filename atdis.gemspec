# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "atdis/version"

Gem::Specification.new do |spec|
  spec.name          = "atdis"
  spec.version       = Atdis::VERSION
  spec.authors       = ["Matthew Landauer"]
  spec.email         = ["matthew@openaustraliafoundation.org.au"]
  spec.description   = "A ruby interface to the application tracking data interchange specification (ATDIS) API"
  spec.summary       = spec.description
  spec.homepage      = "http://github.com/openaustralia/atdis"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.3.1"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rubocop"

  spec.add_dependency "activemodel"
  spec.add_dependency "multi_json", "~> 1.7"
  spec.add_dependency "rest-client"
  spec.add_dependency "rgeo-geojson"
end
