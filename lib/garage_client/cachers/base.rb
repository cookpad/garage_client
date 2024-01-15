# Inherit this abstract class and pass it to garage_client client to cache its responses.
module GarageClient
  module Cachers
    class Base
      def initialize(env)
        @env = env
      end

      def call
        response = store.read(key, options) if read_from_cache?
        if response
          # Faraday::Response#marshal_dump drops the request object
          # https://github.com/lostisland/faraday/blob/cc5d60776645d3d341ff0f425c45b3b3d48d98e0/lib/faraday/response.rb#L70
          response.env.merge!(@env)
        else
          response = yield
          store.write(key, response, options) if written_to_cache?
        end
        response
      end

      private

      # Return boolean to tell if we need to cache the response or not.
      def read_from_cache?
        raise NotImplementedError, "You must implement #{self.class}##{__method__}"
      end

      # Return boolean to tell if we can try to check cache or not.
      def written_to_cache?
        raise NotImplementedError, "You must implement #{self.class}##{__method__}"
      end

      # Return string to cache key to store a given HTTP response.
      def key
        raise NotImplementedError, "You must implement #{self.class}##{__method__}"
      end

      # Return store-object to get or write response (e.g. Rails.cache).
      # This store-object must respond to `fetch(key, options)` method signature.
      def store
        raise NotImplementedError, "You must implement #{self.class}##{__method__}"
      end

      # Return hash table to be used as store's options.
      def options
        {}
      end
    end
  end
end
