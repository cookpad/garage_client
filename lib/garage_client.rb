require 'active_support/all'
require 'faraday'
require 'faraday_middleware'

require 'garage_client/version'
require 'garage_client/cachers/base'
require 'garage_client/configuration'
require 'garage_client/error'
require 'garage_client/request'
require 'garage_client/request/json_encoded'
require 'garage_client/request/pass_over_request_id'
require 'garage_client/response'
require 'garage_client/response/cacheable'
require 'garage_client/response/raise_http_exception'
require 'garage_client/resource'
require 'garage_client/client'

module GarageClient
  class << self
    GarageClient::Configuration.keys.each do |key|
      delegate key, "#{key}=", to: :configuration
    end

    delegate 'default_headers', 'default_headers=', to: :configuration

    def configuration
      @configuration ||= GarageClient::Configuration.new
    end

    def configure(&block)
      configuration.instance_eval(&block)
    end
  end
end
