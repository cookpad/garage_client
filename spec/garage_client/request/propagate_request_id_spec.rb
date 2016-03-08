require "spec_helper"

describe GarageClient::Request::PropagateRequestId do
  let(:client) do
    GarageClient::Client.new
  end

  around do |example|
    original = Thread.current[:request_id]
    Thread.current[:request_id] = 'request_id'
    example.run
    Thread.current[:request_id] = original
  end

  it 'sends request_id via header' do
    stub_get("/examples").with(headers: { 'HTTP_X_REQUEST_ID' => 'request_id' })
    expect { client.get("/examples") }.not_to raise_error
  end

  context 'without request_id' do
    before do
      Thread.current[:request_id] = nil
    end

    it 'does not send request_id via header' do
      stub_get("/examples").with do |request|
        !request.headers.include?('HTTP_X_REQUEST_ID')
      end
      expect { client.get("/examples") }.not_to raise_error
    end
  end

  context 'if already has request_id' do
    let(:client) do
      GarageClient::Client.new(headers: { 'HTTP_X_REQUEST_ID' => 'another_id' })
    end

    it 'does not overwrite request_id' do
      stub_get("/examples").with(headers: { 'HTTP_X_REQUEST_ID' => 'another_id' })
      expect { client.get("/examples") }.not_to raise_error
    end
  end
end
