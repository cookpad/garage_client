require "spec_helper"

describe GarageClient do
  describe ".adapter" do
    it "returns configuration.adapter" do
      described_class.adapter.should == described_class.configuration.adapter
    end
  end

  describe ".endpoint" do
    it "returns configuration.endpoint" do
      described_class.endpoint.should == described_class.configuration.endpoint
    end
  end

  describe ".headers" do
    it "returns configuration.headers" do
      described_class.headers.should == described_class.configuration.headers
    end
  end

  describe ".default_headers" do
    it "returns configuration.headers" do
      described_class.headers.should == described_class.configuration.headers
    end
  end

  describe ".path_prefix" do
    it "returns configuration.path_prefix" do
      described_class.path_prefix.should == described_class.configuration.path_prefix
    end
  end

  describe ".verbose" do
    it "returns configuration.verbose" do
      described_class.verbose.should == described_class.configuration.verbose
    end
  end

  describe ".configure" do
    it "executes given block with configuration object" do
      described_class.configure do |configuration|
        configuration.headers = { "Host" => "example.com" }
      end
      described_class.headers.should == { "Host" => "example.com" }
    end
  end
end
