module GarageClient
  class Response
    class RaiseHttpException < Faraday::Middleware
      ClientErrorStatuses = 400...500
      ServerErrorStatuses = 500...600

      def call(env)
        @app.call(env).on_complete do |response|
          resp = response
          case response[:status].to_i
          when 400
            raise GarageClient::BadRequest.new(resp)
          when 401
            raise GarageClient::Unauthorized.new(resp)
          when 403
            raise GarageClient::Forbidden.new(resp)
          when 404
            raise GarageClient::NotFound.new(resp)
          when 406
            raise GarageClient::NotAcceptable.new(resp)
          when 409
            raise GarageClient::Conflict.new(resp)
          when 415
            raise GarageClient::UnsupportedMediaType.new(resp)
          when 422
            raise GarageClient::UnprocessableEntity.new(resp)
          when 500
            raise GarageClient::InternalServerError.new(resp)
          when 503
            raise GarageClient::ServiceUnavailable.new(resp)
          when 504
            raise GarageClient::GatewayTimeout.new(resp)
          when ClientErrorStatuses
            raise GarageClient::ClientError.new(resp)
          when ServerErrorStatuses
            raise GarageClient::ServerError.new(resp)
          end
        end
      end
    end
  end
end
