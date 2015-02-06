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

  # Check dump data. Because cache data not broken on the version up of faraday.
  describe "check Faraday::Response marshal" do
    specify do
      expect(Faraday::VERSION).to be < "1.0.0", "This spec is no longer needed. Delete this 'describe' section!"
    end

    context "v0.9.1's marshal data" do
      let(:res) do
        Marshal.load(File.read(File.expand_path('../fixtures/faraday_0.9.1_response.dump', __dir__)))
      end

      it "load data" do
        expect(res).to be_instance_of Faraday::Response
        expect(res.env[:body]).to eq fixture("example.yaml")[:body]
      end
    end

    context "v0.8.9's marshal data" do
      let(:res) do
        Marshal.load(File.read(File.expand_path('../fixtures/faraday_0.8.9_response.dump', __dir__)))
      end

      it "load data" do
        expect(res).to be_instance_of Faraday::Response
        expect(res.env[:body]).to eq fixture("example.yaml")[:body]
      end
    end
  end
end
