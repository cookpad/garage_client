require 'spec_helper'
require 'aws/xray'

RSpec.describe 'Tracing support' do
  context 'when `tracing` option is specified' do
    around do |ex|
      Aws::Xray.config.client_options = { sock: io }
      Aws::Xray.trace(name: 'test-app') { ex.run }
    end

    let(:io) { Aws::Xray::TestSocket.new }
    let(:client) do
      GarageClient::Client.new(
        adapter: [:test, stubs],
        endpoint: 'http://127.0.0.1',
        tracing: {
          tracer: 'aws-xray',
          service: 'target-app',
        },
      )
    end
    let(:stubs) do
      Faraday::Adapter::Test::Stubs.new do |stub|
        stub.get('/campain') { |env| [200, {'Content-Type' => 'application/json'}, '{"campain": false}'] }
      end
    end

    specify 'client enables tracing and sends trace data to a local agent' do
      res = client.get('/campain')
      expect(res.body.campain).to eq(false)

      io.rewind
      sent_jsons = io.read.split("\n")
      expect(sent_jsons.size).to eq(2)
      body = JSON.parse(sent_jsons[1])
      expect(body['name']).to eq('target-app')
    end

    context 'API returns client errors' do
      let(:stubs) do
        Faraday::Adapter::Test::Stubs.new do |stub|
          stub.get('/campain') { |env| [404, {'Content-Type' => 'application/json'}, '{"error": "not_found"}'] }
        end
      end

      specify 'client traces HTTP request and response and records errors' do
        expect { client.get('/campain') }.to raise_error(GarageClient::NotFound)

        io.rewind
        sent_jsons = io.read.split("\n")
        expect(sent_jsons.size).to eq(2)
        body = JSON.parse(sent_jsons[1])
        expect(body['name']).to eq('target-app')
        expect(body['error']).to eq(true)
        expect(body['http']['request']['method']).to eq('GET')
        expect(body['http']['response']['status']).to eq(404)
      end
    end

    context 'API returns server errors' do
      let(:stubs) do
        Faraday::Adapter::Test::Stubs.new do |stub|
          stub.get('/campain') { |env| [500, {'Content-Type' => 'application/json'}, '{"error": "internal_server_error"}'] }
        end
      end

      specify 'client traces HTTP request and response and marks as fault' do
        expect { client.get('/campain') }.to raise_error(GarageClient::InternalServerError)

        io.rewind
        sent_jsons = io.read.split("\n")
        expect(sent_jsons.size).to eq(2)
        body = JSON.parse(sent_jsons[1])
        expect(body['name']).to eq('target-app')
        expect(body['error']).to eq(false)
        expect(body['fault']).to eq(true)
        expect(body['http']['request']['method']).to eq('GET')
        expect(body['http']['response']['status']).to eq(500)
      end
    end
  end
end
