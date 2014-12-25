require "spec_helper"

describe GarageClient::Cachers::Base do
  let(:client) do
    GarageClient::Client.new(cacher: cacher_class)
  end

  let(:cacher_class) do
    store = store
    Class.new(GarageClient::Cachers::Base) do
      private

      def key
        @env[:url].to_s
      end

      def read_from_cache?
        true
      end

      def written_to_cache?
        true
      end

      def store
        Class.new do
          def initialize
            @table = {}
          end

          def read(key, options = {})
            @table[key]
          end

          def write(key, value, options = {})
            @table[key] = value
          end
        end.new
      end
    end
  end

  describe "caching" do
    context "with cache-enabled GarageClient::Client" do
      it "caches response along passed cacher class" do
        stub_get("/examples").to_return(fixture("examples.yaml")).times(1)
        stub_get("/example").to_return(fixture("example.yaml")).times(1)
        client.get("/examples").body.should be_a Array
        client.get("/examples").body.should be_a Array
        client.get("/example").body.should be_a GarageClient::Resource
        client.get("/example").body.should be_a GarageClient::Resource
      end
    end
  end
end
