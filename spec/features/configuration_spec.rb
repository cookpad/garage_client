require 'spec_helper'

describe "Configuration of GarageClient" do
  let(:client) { GarageClient::Client.new(options) }
  let(:options) { {} }

  describe "header configuration" do
    before do
      options[:headers] = { "User-Agent" => "my agent" }
    end

    it "sends configured User-Agent" do
      stub_request(:get, "https://garage.example.com/v1/me").
        with(headers: { 'User-Agent'=>'my agent' }).
        to_return(:status => 200, :body => "", :headers => {})

      client.get('/v1/me')
    end
  end

  describe "header configuration with global configuration" do
    around do |example|
      prev = GarageClient.configuration
      GarageClient.instance_variable_set(
        :@configuration,
        GarageClient::Configuration.new(endpoint: "https://garage.example.com", name: "configuration_spec")
      )

      example.run

      GarageClient.instance_variable_set(:@configuration, prev)
    end

    it "uses global configured User-Agent" do
      GarageClient.configure do |c|
        c.headers = { "User-Agent" => "my agent" }
      end

      stub_request(:get, "https://garage.example.com/v1/me").
        with(headers: { 'User-Agent'=>'my agent' }).
        to_return(:status => 200, :body => "", :headers => {})

      client.get('/v1/me')
    end
  end
end
