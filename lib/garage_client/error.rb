module GarageClient
  class Error < StandardError
    attr_accessor :response

    def initialize(response = nil)
      @response = response
    end

    def to_s
      case
      when String === response
        response
      when response.respond_to?(:[]) && response[:method].respond_to?(:upcase) && response[:url].is_a?(URI::HTTP)
        "#{response[:method].upcase} #{response[:url]} #{response[:status]}: #{response[:body]}"
      else
        super
      end
    end
  end

  # HTTP level
  class ClientError < Error; end
  class BadRequest < ClientError; end
  class Unauthorized < ClientError; end
  class Forbidden < ClientError; end
  class NotFound < ClientError; end
  class NotAcceptable < ClientError; end
  class Conflict < ClientError; end
  class UnsupportedMediaType < ClientError; end
  class UnprocessableEntity < ClientError; end

  # Remote Server
  class ServerError < Error; end
  class InternalServerError < ServerError; end
  class ServiceUnavailable < ServerError; end
  class GatewayTimeout < ServerError; end

  # GarageClient Client
  class UnsupportedResource < Error; end
  class InvalidResponseType < Error; end
end
