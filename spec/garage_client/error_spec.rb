require 'spec_helper'

describe GarageClient::Error do
  context 'without argument' do
    it 'raises GarageClient::Error' do
      expect { raise GarageClient::Error }.to raise_error(GarageClient::Error, /GarageClient::Error/)
    end
  end

  context 'with string' do
    let(:message) do
      'error_message'
    end

    it 'raises GarageClient::Error with error message' do
      expect { raise GarageClient::Error, message }.to raise_error(GarageClient::Error, message)
    end
  end

  context 'with Faraday::Response' do
    let(:client) do
      Faraday.new do |builder|
        builder.adapter :test, Faraday::Adapter::Test::Stubs.new do |stub|
          stub.get('/example') { [404, {}, ''] }
        end
      end
    end

    let(:response) do
      client.get('/example')
    end

    it 'raises GarageClient::Error with response summary' do
      expect { raise GarageClient::Error, response.env }.to raise_error(GarageClient::Error, /GET .+ 404/)
    end
  end
end
