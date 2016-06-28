module GarageClient
  class Configuration
    DEFAULTS = {
      adapter: :net_http,
      cacher: nil,
      path_prefix: '/v1',
      verbose: false,
    }

    def self.keys
      DEFAULTS.keys + [:endpoint, :headers]
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

    def name
      options[:name] or raise 'Configuration error: missing name'
    end

    def name=(value)
      options[:name] = value
    end

    def default_user_agent
      "garage_client #{GarageClient::VERSION} #{name}"
    end

    def headers
      options.fetch(:headers) do
        {
          'Accept' => 'application/json',
          'User-Agent' => default_user_agent,
        }
      end
    end

    def headers=(value)
      options[:headers] = value
    end

    alias :default_headers :headers
    alias :default_headers= :headers=
  end
end
