require "spec_helper"

describe GarageClient::Configuration do
  let(:configuration) do
    described_class.new
  end

  describe "#adapter" do
    context "in default configuration" do
      it "returns :net_http" do
        configuration.adapter.should == :net_http
      end
    end

    context "after configured" do
      before do
        configuration.adapter = :test
      end

      it "returns configured value" do
        configuration.adapter.should == :test
      end
    end
  end

  describe "#endpoint" do
    context "not configured" do
      it "raises RuntimeError" do
        expect { configuration.endpoint }.to raise_error(RuntimeError, /missing endpoint/)
      end
    end

    context "after configured" do
      before do
        configuration.endpoint = "http://example.com"
      end

      it "returns configured value" do
        configuration.endpoint.should == "http://example.com"
      end
    end
  end

  describe "#headers" do
    context "name isn't configured" do
      it "raises RuntimeError" do
        expect { configuration.headers }.to raise_error(RuntimeError, /missing name/)
      end
    end

    context "in default configuration" do
      let(:name) { 'configuration_spec' }

      before do
        configuration.name = name
      end

      it "returns default headers as Hash" do
        configuration.headers.should == {
          "Accept" => "application/json",
          "User-Agent" => "garage_client #{GarageClient::VERSION} #{name}",
        }
      end
    end

    context "after configured" do
      before do
        configuration.headers = { "HTTP_ACCEPT" => "application/json" }
      end

      it "returns configured value" do
        configuration.headers.should == { "HTTP_ACCEPT" => "application/json" }
      end
    end
  end

  describe "#default_headers" do
    before do
      configuration.name = 'configuration_spec'
    end

    it "returns configuration.headers" do
      configuration.default_headers.should == configuration.headers
    end
  end

  describe "#path_prefix" do
    context "in default configuration" do
      it "returns /v1" do
        configuration.path_prefix.should == "/v1"
      end
    end

    context "after configured" do
      before do
        configuration.path_prefix = "/v2"
      end

      it "returns configured value" do
        configuration.path_prefix.should == "/v2"
      end
    end
  end

  describe "#verbose" do
    context "in default configuration" do
      it "returns false" do
        configuration.verbose.should == false
      end
    end

    context "after configured" do
      before do
        configuration.verbose = nil
      end

      it "returns configured value" do
        configuration.verbose.should == nil
      end
    end
  end
end
