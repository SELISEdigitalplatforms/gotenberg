# frozen_string_literal: true

require_relative "lib/gotenberg/version"

Gem::Specification.new do |spec|
  spec.name = "gotenberg"
  spec.version = Gotenberg::VERSION
  spec.licenses = ["MIT"]
  spec.authors = %w[bugloper teknatha136]
  spec.email = ["bugloper@gmail.com"]

  spec.summary = "A simple Ruby client for gotenberg"
  spec.description = "A simple Ruby client for gotenberg"
  spec.homepage = "https://github.com/SELISEdigitalplatforms/gotenberg"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/SELISEdigitalplatforms/gotenberg"
  spec.metadata["changelog_uri"] = "https://github.com/SELISEdigitalplatforms/gotenberg/blob/main/CHANGELOG.md"
  File.basename(__FILE__)
  spec.files = Dir["lib/**/*.rb"]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency "mime-types"
  spec.add_dependency "multipart-post", "~> 2.1"
  # rubocop:disable Gemspec/RequireMFA
  spec.metadata["rubygems_mfa_required"] = "false"
  # rubocop:enable Gemspec/RequireMFA
end
