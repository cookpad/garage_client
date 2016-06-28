require 'spec_helper'

describe GarageClient::Client do
  let(:client) { GarageClient::Client.new(options) }
  let(:options) { {} }

  describe 'laziness of properties' do
    before { allow(GarageClient.configuration).to receive(:endpoint).and_raise('error') }

    context 'when is specified options' do
      let(:options) { { endpoint: 'http://example.com' } }

      it 'does not evaluate global configuration' do
        expect { client.endpoint }.not_to raise_error
      end
    end

    context 'when is not specified options' do
      it 'evaluates global configuration' do
        expect { client.endpoint }.to raise_error('error')
      end
    end
  end

  describe "#adapter" do
    context "without :adapter option value" do
      it "returns default value" do
        client.adapter.should == GarageClient.configuration.adapter
      end
    end

    context "with :adapter option value" do
      before do
        options[:adapter] = :test
      end

      it "returns it" do
        client.adapter.should == :test
      end
    end
  end

  describe "#endpoint" do
    context "without :endpoint option value" do
      it "returns default value" do
        client.endpoint.should == GarageClient.configuration.endpoint
      end
    end

    context "with :endpoint option value" do
      before do
        options[:endpoint] = "http://example.com"
      end

      it "returns it" do
        client.endpoint.should == "http://example.com"
      end
    end
  end

  describe "#path_prefix" do
    context "without :path_prefix option value" do
      it "returns default value" do
        client.path_prefix.should == GarageClient.configuration.path_prefix
      end
    end

    context "with :path_prefix option value" do
      before do
        options[:path_prefix] = "/v2"
      end

      it "returns it" do
        client.path_prefix.should == "/v2"
      end
    end
  end

  describe "#verbose" do
    context "without :verbose option value" do
      it "returns default value" do
        client.verbose.should == GarageClient.configuration.verbose
      end
    end

    context "with :verbose option value" do
      before do
        options[:verbose] = nil
      end

      it "returns it" do
        client.verbose.should == nil
      end
    end
  end

  describe "#headers" do
    context "without :headers option value" do
      it "returns default value" do
        client.headers.should == GarageClient.configuration.headers
      end
    end

    context "with :headers option value" do
      before do
        options[:headers] = { "Content-Type" => "text/plain" }
      end

      it "returns headers merged with default values" do
        client.headers.should == {
          "Accept" => "application/json",
          "Content-Type" => "text/plain",
          "User-Agent" => "garage_client #{GarageClient::VERSION} garage_client_spec"
        }
      end
    end

    context "with User-Agent header option" do
      before do
        options[:headers] = { "User-Agent" => "my agent" }
      end

      it "returns changed User-Agent" do
        client.headers["User-Agent"].should eq "my agent"
      end
    end
  end

  describe "authorization" do
    before do
      client.access_token = 'abc'
      stub_get('/example').with(
        headers: {
          'Accept' => 'application/json',
          'Accept-Encoding' => /.*/,
          'User-Agent' => /.*/,
          'Authorization' => 'Bearer abc'
        }
      ).to_return(fixture('example.yaml'))
    end

    it "requests with expected beaer authorization header" do
      expect { client.get('/example') }.not_to raise_error
    end
  end

  describe "#adapter=" do
    it "overwrites it" do
      client.adapter = :test
      client.adapter.should == :test
    end
  end

  describe "#endpoint=" do
    it "overwrites it" do
      client.endpoint = "http://example.com"
      client.endpoint.should == "http://example.com"
    end
  end

  describe "#headers=" do
    it "updates merged headers" do
      client.headers = { "Content-Type" => "text/plain" }
      client.headers.should == { "Content-Type" => "text/plain" }
    end
  end

  describe "#path_prefix=" do
    it "overwrites it" do
      client.adapter = "/v2"
      client.adapter.should == "/v2"
    end
  end

  describe "#verbose=" do
    it "overwrites it" do
      client.verbose = nil
      client.verbose.should == nil
    end
  end

  describe '#get' do
    context 'with collection resource' do
      before do
        stub_get('/examples').to_return(fixture('examples.yaml'))
      end

      it 'returns response' do
        response = client.get('/examples')
        response.should be_kind_of(GarageClient::Response)
        response.body.should be_kind_of(Array)
        response.body.first.should be_kind_of(GarageClient::Resource)
      end
    end

    context 'with single resource' do
      before do
        stub_get('/examples/1').to_return(fixture('example.yaml'))
      end

      it 'returns response' do
        response = client.get('/examples/1')
        response.should be_kind_of(GarageClient::Response)
        response.body.should be_kind_of(GarageClient::Resource)
      end
    end
  end

  describe '#post' do
    before do
      stub_post('/examples').to_return(fixture('example.yaml'))
    end

    it 'returns created resource' do
      response = client.post('/examples', :name => 'example name')
      response.should be_kind_of(GarageClient::Response)
      response.body.should be_kind_of(GarageClient::Resource)
    end
  end

  describe '#me' do
    before do
      stub_get('/me').to_return(fixture('example.yaml'))
    end

    it 'returns response' do
      response = client.me
      response.should be_kind_of(GarageClient::Response)
      response.body.should be_kind_of(GarageClient::Resource)
    end
  end

  describe 'validation' do
    context 'when endpoint configuration is missing' do
      around do |example|
        old, GarageClient.endpoint = GarageClient.endpoint, nil
        example.run
        GarageClient.endpoint = old
      end

      it 'raises RuntimeError' do
        expect { client }.to raise_error(RuntimeError, /missing endpoint/)
      end
    end
  end
end
