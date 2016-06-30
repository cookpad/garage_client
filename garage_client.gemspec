# -*- encoding: utf-8 -*-
$:.unshift File.expand_path("../lib", __FILE__)
require 'garage_client/version'

Gem::Specification.new do |s|
  s.version       = GarageClient::VERSION
  s.name          = "garage_client"
  s.homepage      = "https://github.com/cookpad/garage_client"
  s.summary       = "Ruby client library for the Garage API"
  s.description   = s.summary

  s.files         = `git ls-files`.split($\)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']
  s.authors       = ['Cookpad Inc.']
  s.email         = ['kaihatsu@cookpad.com']

  s.add_dependency 'activesupport', '> 3.2.0'
  s.add_dependency 'faraday', '>= 0.8.0'
  s.add_dependency 'faraday_middleware'
  s.add_dependency 'hashie', '>= 1.2.0'
  s.add_dependency 'link_header'

  s.add_dependency 'system_timer' if RUBY_VERSION < '1.9'

  s.add_development_dependency "rails"
  s.add_development_dependency "rake", ">= 0.9.2"
  s.add_development_dependency "rspec"
  s.add_development_dependency "json"
  s.add_development_dependency "webmock"
  s.add_development_dependency "pry"
  # Until bug fixed: https://github.com/colszowka/simplecov/issues/281
  s.add_development_dependency "simplecov", "~> 0.7.1"
end
