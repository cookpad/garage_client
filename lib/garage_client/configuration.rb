module GarageClient
  class Configuration
    DEFAULTS = {
      adapter: :net_http,
      cacher: nil,
      headers: {
        'Accept' => 'application/json',
        'User-Agent' => "garage_client #{GarageClient::VERSION}",
      },
      path_prefix: '/v1',
      verbose: false,
      request: nil,
    }

    def self.keys
      DEFAULTS.keys + [:endpoint]
    end

    def initialize(options = {})
      @options = options
    end

    def options
      @options ||= {}
    end

    def reset
      @options = nil
    end

    DEFAULTS.keys.each do |key|
      define_method(key) do
        options.fetch(key, DEFAULTS[key])
      end

      define_method("#{key}=") do |value|
        options[key] = value
      end
    end

    def endpoint
      options[:endpoint] or raise 'Configuration error: missing endpoint'
    end

    def endpoint=(value)
      options[:endpoint] = value
    end

    alias :default_headers :headers
    alias :default_headers= :headers=
  end
end
