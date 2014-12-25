module GarageClient
  module Request
    class JsonEncoded < Faraday::Middleware
      def call(env)
        request = Request.new(env)

        if request.json_compatible?
          env[:request_headers]["Content-Type"] ||= "application/json"
          env[:body] = env[:body].to_json
        end

        @app.call(env)
      end

      class Request
        attr_reader :env

        def initialize(env)
          @env = env
        end

        def json_compatible?
          has_json_compatible_body? && has_json_compatible_content_type?
        end

        private

        def has_json_compatible_content_type?
          headers["Content-Type"].nil? || headers["Content-Type"] == "application/json"
        end

        def has_json_compatible_body?
          case body
          when nil
            false
          when Array, Hash
            true
          end
        end

        def body
          env[:body]
        end

        def headers
          env[:request_headers]
        end

        def has_json_content_type?
          headers["Content-Type"] == "application/json"
        end

        def has_content_type?
          !headers["Content-Type"].nil?
        end
      end
    end
  end
end
