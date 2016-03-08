module GarageClient
  module Request
    class PropagateRequestId < Faraday::Middleware
      def call(env)
        if Thread.current[:request_id] && !env[:request_headers]["HTTP_X_REQUEST_ID"]
          env[:request_headers]["HTTP_X_REQUEST_ID"] = Thread.current[:request_id]
        end
        @app.call(env)
      end
    end
  end
end
