require 'rubygems'
require 'pry'
require 'uri'
require 'rspec'
require 'webmock/rspec'

if ENV["COVERAGE"]
  require 'simplecov'
  SimpleCov.start do
    if ENV["RUN_CI"]
      # Only with mri_19
      require 'simplecov-rcov'
      SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
    end
  end
end

require 'garage_client'

GarageClient.configure do |c|
  c.path_prefix = ''
  c.endpoint = "https://garage.example.com"
  c.name = 'garage_client_spec'
end

# This workaround is strictly for stubbing purpose.
def make_endpoint(path)
  /^(http|https):\/\//.match(path) ? path : URI.join(GarageClient.endpoint, path).to_s
end

def stub_get(path)
  stub_request(:get, make_endpoint(path))
end

def stub_post(path)
  stub_request(:post, make_endpoint(path))
end

def stub_put(path)
  stub_request(:put, make_endpoint(path))
end

def stub_delete(path)
  stub_request(:delete, make_endpoint(path))
end

def fixture(file)
  prefix = File.expand_path('../fixtures', __FILE__)
  path = File.join(prefix, file)
  HashWithIndifferentAccess.new(YAML.load_file(path))
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end
