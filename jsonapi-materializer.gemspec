#!/usr/bin/env ruby

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require("jsonapi/materializer/version")

Gem::Specification.new do |spec|
  spec.name = "jsonapi-materializer"
  spec.version = JSONAPI::Materializer::VERSION
  spec.authors = ["Kurtis Rainbolt-Greene"]
  spec.email = ["kurtis@rainbolt-greene.online"]
  spec.summary = "A way to turn data models into outbound json:api responses"
  spec.description = spec.summary
  spec.homepage = "http://krainboltgreene.github.io/jsonapi-materializer"
  spec.license = "ISC"

  spec.files = Dir[File.join("lib", "**", "*"), "LICENSE", "README.md", "Rakefile"]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r(^exe/)) {|f| File.basename(f)}
  spec.require_paths = ["lib"]

  spec.add_development_dependency("activemodel", ">= 4.0.0", ">= 4.2", ">= 5.0.0", ">= 5.1")
  spec.add_development_dependency("activerecord", ">= 4.0.0", ">= 4.2", ">= 5.0.0", ">= 5.1")
  spec.add_development_dependency("bundler", "~> 1.16")
  spec.add_development_dependency("pry", "~> 0.11")
  spec.add_development_dependency("pry-doc", "~> 0.11")
  spec.add_development_dependency("rake", "~> 12.2")
  spec.add_development_dependency("rspec", "~> 3.7")
  spec.add_development_dependency("rubocop")
  spec.add_development_dependency("sqlite3", "~> 1.3")
  spec.add_runtime_dependency("activesupport", ">= 4.0.0", ">= 4.2", ">= 5.0.0", ">= 5.1")
  spec.add_runtime_dependency("addressable", "~> 2.5  ")
  spec.add_runtime_dependency("kaminari", "~> 1.1")
end
