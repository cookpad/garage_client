require "link_header"

module GarageClient
  class Response
    MIME_DICT = %r{application/vnd\.cookpad\.dictionary\+(json|x-msgpack)}
    ACCEPT_BODY_TYPES = [Array, Hash, NilClass]

    attr_accessor :client, :response

    def initialize(client, response)
      @client = client
      @response = response

      # faraday-net_http adapter converts the response body from nil to '' to ensure the body is a string.
      # https://github.com/lostisland/faraday/commit/f41ffaabb72d3700338296c79a2084880e6a9843
      # https://github.com/lostisland/faraday-net_http/blob/11953160f75dd488133a74857c2b07d41be8995d/lib/faraday/adapter/net_http.rb#L186
      response.env[:body] = nil if response.env[:body] == ''

      unless ACCEPT_BODY_TYPES.any? {|type| type === response.body }
        raise GarageClient::InvalidResponseType, "Invalid response type (#{response.body.class}): #{response.body}"
      end
    end

    def link
      @link ||= response.headers['Link']
    end

    def total_count
      unless @total_count
        @total_count = response.headers['X-List-TotalCount']
        @total_count = @total_count.to_i if @total_count
      end
      @total_count
    end

    def body
      @body ||= case response.body
                when Array
                  response.body.map {|res| GarageClient::Resource.new(client, res) }
                when Hash
                  if dictionary_response?
                    Hash[response.body.map {|id, res| [id, GarageClient::Resource.new(client, res)] }]
                  else
                    GarageClient::Resource.new(client, response.body)
                  end
                when NilClass
                  nil
                end
    end

    def next_page_path
      next_page_link.try(:href)
    end

    def prev_page_path
      prev_page_link.try(:href)
    end

    def first_page_path
      first_page_link.try(:href)
    end

    def last_page_path
      last_page_link.try(:href)
    end

    def has_next_page?
      !!next_page_link
    end

    def has_prev_page?
      !!prev_page_link
    end

    def has_first_page?
      !!first_page_link
    end

    def has_last_page?
      !!last_page_link
    end

    def next_page_link
      parsed_link_header.try(:find_link, %w[rel next])
    end

    def prev_page_link
      parsed_link_header.try(:find_link, %w[rel prev])
    end

    def first_page_link
      parsed_link_header.try(:find_link, %w[rel first])
    end

    def last_page_link
      parsed_link_header.try(:find_link, %w[rel last])
    end

    def respond_to_missing?(name, include_private)
      body.respond_to?(name, include_private)
    end

    private

    def method_missing(name, *args, &block)
      body.send(name, *args, &block)
    end

    def dictionary_response?
      response.headers['Content-Type'] =~ MIME_DICT
    end

    def parsed_link_header
      @parsed_link_header ||= LinkHeader.parse(link) if link
    end
  end
end
