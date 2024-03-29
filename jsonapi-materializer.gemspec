#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative("lib/jsonapi/materializer/version")

Gem::Specification.new do |spec|
  spec.name = "jsonapi-materializer"
  spec.version = JSONAPI::Materializer::VERSION
  spec.authors = ["Kurtis Rainbolt-Greene"]
  spec.email = ["kurtis@rainbolt-greene.online"]
  spec.summary = "A way to turn data models into outbound json:api responses"
  spec.description = spec.summary
  spec.homepage = "https://github.com/krainboltgreene/jsonapi-materializer.rb"
  spec.license = "HL3"
  spec.required_ruby_version = "~> 3.2"

  spec.files = Dir[File.join("lib", "**", "*"), "LICENSE", "README.md", "Rakefile"]
  spec.require_paths = ["lib"]
  spec.add_runtime_dependency("activesupport")
  spec.add_runtime_dependency("addressable")
  spec.add_runtime_dependency("kaminari")
  spec.metadata["rubygems_mfa_required"] = "true"
end
