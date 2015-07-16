module GarageClient
  class Client
    include GarageClient::Request

    def self.property(key)
      define_method(key) do
        options.fetch(key) { GarageClient.configuration.send(key) }
      end

      define_method("#{key}=") do |value|
        options[key] = value
      end
    end

    attr_reader :options

    property :adapter
    property :cacher
    property :endpoint
    property :path_prefix
    property :verbose

    def initialize(options = {})
      require_necessaries(options)
      @options = options
    end

    def headers
      @headers ||= GarageClient.configuration.headers.merge(given_headers.stringify_keys)
    end
    alias :default_headers :headers

    def headers=(value)
      @headers = value
    end
    alias :default_headers= :headers=

    def access_token
      options[:access_token]
    end

    def access_token=(value)
      options[:access_token] = value
    end

    def me(params = {}, options = {})
      get('/me', params, options)
    end

    def conn
      @conn ||= connection
    end

    def apply_auth_middleware(faraday_builder)
      faraday_builder.authorization :Bearer, access_token if access_token
    end

    def connection
      Faraday.new(headers: headers, url: endpoint, request: request_options) do |builder|
        # Response Middlewares
        builder.use Faraday::Response::Logger if verbose
        builder.use FaradayMiddleware::Mashify
        builder.use Faraday::Response::ParseJson, :content_type => /\bjson$/
        builder.use GarageClient::Response::Cacheable, cacher: cacher if cacher
        builder.use GarageClient::Response::RaiseHttpException

        # Request Middlewares
        builder.use Faraday::Request::Multipart
        builder.use GarageClient::Request::JsonEncoded

        # Low-level Middlewares
        apply_auth_middleware builder
        builder.adapter(*adapter)
      end
    end

    def request_options
      options[:request] || default_options.options[:request]
    end

    def request_options=(value)
      options[:request] = value
    end

    private

    def given_headers
      options[:headers] || options[:default_headers] || {}
    end

    def require_necessaries(options)
      if !options[:endpoint] && !default_options.endpoint
        raise "Missing endpoint configuration"
      end
    end

    def default_options
      GarageClient.configuration
    end
  end
end
