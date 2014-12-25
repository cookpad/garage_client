require "hashie"

module GarageClient
  class Resource
    attr_accessor :data, :client

    def self.resource?(hash)
      hash.kind_of?(Hash) && hash.has_key?('_links')
    end

    def initialize(client, data)
      @client = client
      @data = Hashie::Mash.new(data)
    end

    def properties
      @properties ||= data.keys.map(&:to_sym)
    end

    def links
      @links ||= data._links ? data._links.keys.map(&:to_sym) : []
    end

    def self_path
      @self_path ||= data._links.self.href
    end

    def update(body = nil, options = {})
      client.put(self_path, body, options)
    end

    def destroy(options = {})
      client.delete(self_path, options)
    end

    def method_missing(name, *args, &block)
      if properties.include?(name)
        value = data[name]
        if self.class.resource?(value)
          GarageClient::Resource.new(client, value)
        else
          value
        end
      elsif links.include?(name)
        path = data._links[name].href
        client.get(path, *args)
      elsif nested_resource_creation_method?(name)
        path = data._links[name.to_s.sub(/create_/, '')].href
        client.post(path, *args)
      else
        super
      end
    end

    def respond_to?(name)
      super || !!(properties.include?(name) || links.include?(name) || nested_resource_creation_method?(name))
    end

    def nested_resource_creation_method?(name)
      !!(name =~ /\Acreate_(.+)\z/ && links.include?($1.to_sym))
    end
  end
end
