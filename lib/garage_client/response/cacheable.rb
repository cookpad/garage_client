module GarageClient
  class Response
    class Cacheable < Faraday::Middleware
      register_middleware cache: self

      def initialize(app, args)
        super(app)
        @cacher_class = args[:cacher]
        validate!
      end

      def call(env)
        @cacher_class.new(env).call { @app.call(env) }
      end

      private

      def validate!
        unless @cacher_class
          raise ArgumentError, "You must pass cacher_class to #{self.class}.new"
        end
      end
    end
  end
end
