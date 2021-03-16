require 'faraday'
require 'faraday_middleware'

require 'garage_client/version'
require 'garage_client/cachers/base'
require 'garage_client/configuration'
require 'garage_client/error'
require 'garage_client/request'
require 'garage_client/request/json_encoded'
require 'garage_client/request/propagate_request_id'
require 'garage_client/response'
require 'garage_client/response/cacheable'
require 'garage_client/response/raise_http_exception'
require 'garage_client/resource'
require 'garage_client/client'

begin
  require 'rails'
rescue LoadError
else
  require 'garage_client/railtie'
end

module GarageClient
  class << self
    [*GarageClient::Configuration.keys, :default_headers].each do |key|
      define_method(key) do
        configuration.public_send(key)
      end

      define_method("#{key}=") do |value|
        configuration.public_send("#{key}=", value)
      end
    end

    def configuration
      @configuration ||= GarageClient::Configuration.new
    end

    def configure(&block)
      configuration.instance_eval(&block)
    end
  end
end
