require "spec_helper"

describe GarageClient::Request::JsonEncoded do
  let(:client) do
    GarageClient::Client.new(headers: headers)
  end

  let(:headers) do
    {}
  end

  let(:params) do
    { key: "value" }
  end

  context "with Content-Type: application/json" do
    let(:headers) do
      { "Content-Type" => "application/json" }
    end

    it "encodes request body to JSON" do
      stub_post("/examples").with(body: params.to_json)
      expect { client.post("/examples", params) }.not_to raise_error
    end
  end

  context "without Content-Type" do
    it "encodes request body to JSON" do
      stub_post("/examples").with(body: params.to_json)
      expect { client.post("/examples", params) }.not_to raise_error
    end
  end

  context "without body" do
    let(:params) do
      nil
    end

    it "does nothing" do
      stub_post("/examples").with(body: nil)
      expect { client.post("/examples", params) }.not_to raise_error
    end
  end


  context "with Content-Type: multipart/form-data" do
    let(:headers) do
      { "Content-Type" => "multipart/form-data" }
    end

    it "does nothing" do
      # https://github.com/bblimke/webmock/commit/93ef063a043a222774fd339b3a56a428feab813f
      pending 'webmock does not support matching body for multipart/form-data'

      stub_post("/examples").with(
        body: [
          "-------------RubyMultipartPost",
          "Content-Disposition: form-data; name=\"key\"",
          "",
          "value",
          "-------------RubyMultipartPost--",
          "",
          "",
        ].join("\r\n")
      )
      expect { client.post("/examples", params) }.not_to raise_error
    end
  end
end
