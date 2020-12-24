module GarageClient
  module Request
    class PropagateRequestId < Faraday::Middleware
      def call(env)
        if Thread.current[:request_id] && !env[:request_headers]["X-Request-Id"]
          env[:request_headers]["X-Request-Id"] = Thread.current[:request_id]
        end
        @app.call(env)
      end
    end
  end
end
