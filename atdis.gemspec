# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "atdis/version"

Gem::Specification.new do |spec|
  spec.name          = "atdis"
  spec.version       = Atdis::VERSION
  spec.authors       = ["Matthew Landauer"]
  spec.email         = ["matthew@oaf.org.au"]
  spec.summary       = "A Ruby interface to the ATDIS planning application specification"
  spec.description   =
    "A Ruby interface for reading and validating planning application data feeds " \
    "that follow the Application Tracking Data Interchange Specification (ATDIS)"
  spec.homepage      = "https://github.com/openaustralia/atdis"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/openaustralia/atdis"
  spec.metadata["changelog_uri"] = "https://github.com/openaustralia/atdis/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files         = `git ls-files`.split("\n")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 3.2"

  spec.add_dependency "activemodel"
  spec.add_dependency "activesupport"
  spec.add_dependency "multi_json", "~> 1.7"
  spec.add_dependency "rest-client"
  spec.add_dependency "rgeo-geojson"
end
