require "spec_helper"

describe GarageClient::Cachers::Base do
  let(:store) do
    Class.new do
      def initialize
        @table = {}
      end

      def read(key, options = {})
        value = @table[key]
        Marshal.load(value) if value
      end

      def write(key, value, options = {})
        @table[key] = Marshal.dump(value)
      end
    end.new
  end

  let(:cacher_class) do
    cache_store = store
    Class.new(GarageClient::Cachers::Base) do
      @store = cache_store

      class << self
        attr_reader :store
      end

      delegate :store, to: :class

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
    end
  end

  let(:client) do
    GarageClient::Client.new(cacher: cacher_class)
  end

  describe "caching" do
    context "with cache-enabled GarageClient::Client" do
      it "caches response along passed cacher class" do
        stub_get("/examples").to_return(fixture("examples.yaml")).times(1).then.to_raise("Not use Cache.")
        stub_get("/example").to_return(fixture("example.yaml")).times(1).then.to_raise("Not use Cache.")
        client.get("/examples").body.should be_a Array
        client.get("/examples").body.should be_a Array
        client.get("/example").body.should be_a GarageClient::Resource
        client.get("/example").body.should be_a GarageClient::Resource
      end
    end
  end
end
