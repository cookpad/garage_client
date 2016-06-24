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
  class BadRequest < Error; end
  class Unauthorized < Error; end
  class Forbidden < Error; end
  class NotFound < Error; end
  class NotAcceptable < Error; end
  class Conflict < Error; end
  class UnsupportedMediaType < Error; end
  class UnprocessableEntity < Error; end
  class ClientError < Error; end

  # Remote Server
  class ServerError < Error; end
  class InternalServerError < ServerError; end
  class ServiceUnavailable < ServerError; end

  # GarageClient Client
  class UnsupportedResource < Error; end
  class InvalidResponseType < Error; end
end
