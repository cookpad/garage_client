module GarageClient
  module Request
    MIME_DICT = 'application/vnd.cookpad.dictionary+json'

    def get(path, params = nil, options = {})
      request(:get, path, params, nil, options)
    end

    def post(path, body = nil, options = {})
      request(:post, path, {}, body, options)
    end

    def put(path, body = nil, options = {})
      request(:put, path, {}, body, options)
    end

    def delete(path, options = {})
      request(:delete, path, options)
    end

    private
    def request(method, path, params = {}, body = nil, options = {})
      response = conn.send(method) do |request|
        request.url(path, params)
        request.body = body if body
        request.headers.update(options[:headers]) if options[:headers]
        request.options.timeout = options[:timeout] if options[:timeout]
        request.options.open_timeout = options[:open_timeout] if options[:open_timeout]
      end
      options[:raw] ? response : GarageClient::Response.new(self, response)
    end

    def request_with_prefix(method, path, *args)
      path = "#{path_prefix}#{path}" unless path.start_with?(path_prefix)
      request_without_prefix(method, path, *args)
    end
    alias request_without_prefix request
    alias request request_with_prefix
  end
end
