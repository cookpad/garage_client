require 'spec_helper'

describe GarageClient::Response do
  let(:response) do
    described_class.new(client, raw_response)
  end

  let(:client) do
    GarageClient::Client.new
  end

  let(:raw_response) do
    double(headers: headers, body: env.body, env: env)
  end

  let(:headers) do
    { 'Link' => link }
  end

  let(:env) do
    double(:env, body: body).tap do |e|
      allow(e).to receive(:[]).with(:body).and_return(body)
    end
  end

  let(:body) do
    {}
  end

  let(:link) do
    %w[
      </v1/examples?page=1>; rel="first",
      </v1/examples?page=2>; rel="prev",
      </v1/examples?page=4>; rel="next",
      </v1/examples?page=5>; rel="last"
    ].join(" ")
  end

  describe "#respond_to?" do
    context "with same property" do
      before do
        body["name"] = "example"
      end

      it "returns true" do
        response.respond_to?(:name).should == true
      end
    end

    context "with same method" do
      it "returns true" do
        response.respond_to?(:body).should == true
      end
    end

    context "with neithor same property nor same method" do
      it "returns false" do
        response.respond_to?(:name).should == false
      end
    end

    context "with private method name and no include_private option" do
      it "returns false" do
        response.respond_to?(:parsed_link_header).should == false
      end
    end

    context "with private method name and include_private option" do
      it "returns true" do
        response.respond_to?(:parsed_link_header, true).should == true
      end
    end
  end

  describe "#method" do
    context "with same property" do
      before do
        body["name"] = "example"
      end

      it "returns method object" do
        response.method(:name).should be_kind_of(Method)
      end
    end

    context "with neithor same property nor same method" do
      it "raises an error" do
        expect { response.method(:name) }.to raise_error(NameError)
      end
    end
  end

  describe "#has_next_page?" do
    context "without Link header" do
      before do
        headers.delete("Link")
      end

      it "returns false" do
        response.has_next_page?.should == false
      end
    end

    context "without next link" do
      let(:link) do
        ""
      end

      it "returns false" do
        response.has_next_page?.should == false
      end
    end

    context "with next link" do
      it "returns true" do
        response.has_next_page?.should == true
      end
    end
  end

  describe "#has_prev_page?" do
    context "without Link header" do
      before do
        headers.delete("Link")
      end

      it "returns false" do
        response.has_prev_page?.should == false
      end
    end

    context "without prev link" do
      let(:link) do
        ""
      end

      it "returns false" do
        response.has_prev_page?.should == false
      end
    end

    context "with prev link" do
      it "returns true" do
        response.has_prev_page?.should == true
      end
    end
  end

  describe "#has_first_page?" do
    context "without Link header" do
      before do
        headers.delete("Link")
      end

      it "returns false" do
        response.has_first_page?.should == false
      end
    end

    context "without first link" do
      let(:link) do
        ""
      end

      it "returns false" do
        response.has_first_page?.should == false
      end
    end

    context "with first link" do
      it "returns true" do
        response.has_first_page?.should == true
      end
    end
  end

  describe "#has_last_page?" do
    context "without Link header" do
      before do
        headers.delete("Link")
      end

      it "returns false" do
        response.has_last_page?.should == false
      end
    end

    context "without last link" do
      let(:link) do
        ""
      end

      it "returns false" do
        response.has_last_page?.should == false
      end
    end

    context "with last link" do
      it "returns true" do
        response.has_last_page?.should == true
      end
    end
  end

  describe "#next_page_path" do
    context "without Link header" do
      before do
        headers.delete("Link")
      end

      it "returns nil" do
        response.next_page_path.should == nil
      end
    end

    context "without next link" do
      let(:link) do
        ""
      end

      it "returns nil" do
        response.next_page_path.should == nil
      end
    end

    context "with next link" do
      it "returns next page path" do
        response.next_page_path.should == "/v1/examples?page=4"
      end
    end
  end

  describe "#prev_page_path" do
    context "without Link header" do
      before do
        headers.delete("Link")
      end

      it "returns nil" do
        response.prev_page_path.should == nil
      end
    end

    context "without prev link" do
      let(:link) do
        ""
      end

      it "returns nil" do
        response.prev_page_path.should == nil
      end
    end

    context "with prev link" do
      it "returns prev page path" do
        response.prev_page_path.should == "/v1/examples?page=2"
      end
    end
  end

  describe "#first_page_path" do
    context "without Link header" do
      before do
        headers.delete("Link")
      end

      it "returns nil" do
        response.first_page_path.should == nil
      end
    end

    context "without first link" do
      let(:link) do
        ""
      end

      it "returns nil" do
        response.first_page_path.should == nil
      end
    end

    context "with first link" do
      it "returns first page path" do
        response.first_page_path.should == "/v1/examples?page=1"
      end
    end
  end

  describe "#last_page_path" do
    context "without Link header" do
      before do
        headers.delete("Link")
      end

      it "returns nil" do
        response.last_page_path.should == nil
      end
    end

    context "without last link" do
      let(:link) do
        ""
      end

      it "returns nil" do
        response.last_page_path.should == nil
      end
    end

    context "with last link" do
      it "returns last page path" do
        response.last_page_path.should == "/v1/examples?page=5"
      end
    end
  end
end

describe Faraday::Response do
  let(:mime_dict) { 'application/vnd.cookpad.dictionary+json' }
  let(:client) { GarageClient::Client.new }
  let(:response) { client.get('/examples') }

  describe '#link' do
    context 'with resources collection' do
      context 'without paginated resources' do
        before do
          stub_get('/examples').to_return(fixture('examples_without_pagination.yaml'))
        end

        it 'returns link header' do
          response.link.should be_nil
        end
      end

      context 'with paginated resources' do
        before do
          stub_get('/examples').to_return(fixture('examples.yaml'))
        end

        it 'returns link header' do
          response.link.should == %q{</v1/examples?page=2&per_page=1>; rel="next"}
        end
      end
    end
  end

  describe '#total_count' do
    context 'with resources collection' do
      context 'without paginated resources' do
        before do
          stub_get('/examples').to_return(fixture('examples_without_pagination.yaml'))
        end

        it 'returns nil' do
          response.total_count.should be_nil
        end
      end

      context 'with paginated resources' do
        before do
          stub_get('/examples').to_return(fixture('examples.yaml'))
        end

        it 'returns total count' do
          response.total_count.should == 1
        end
      end
    end
  end

  describe '#body' do
    let(:single_response) { client.get('/examples/1') }
    let(:array_response) { client.get('/examples') }
    let(:dictionary_response) { client.get('/examples', nil, :headers => { 'Accept' => mime_dict }) }

    context 'with single resource' do
      let(:response) { single_response }

      before do
        stub_get('/examples/1').to_return(fixture('example.yaml'))
      end

      it 'returns resource' do
        response.body.should be_kind_of(GarageClient::Resource)
      end
    end

    context 'with resources collection' do
      context 'with array response' do
        let(:response) { array_response }

        before do
          stub_get('/examples').to_return(fixture('examples.yaml'))
        end

        it 'returns resources array' do
          response.body.should be_kind_of(Array)
          response.body.first.should be_kind_of(GarageClient::Resource)
        end
      end

      context 'with dictionary response' do
        let(:response) { dictionary_response }

        before do
          stub_get('/examples').to_return(fixture('examples_dictionary.yaml'))
        end

        it 'returns resources array' do
          response.body.should be_kind_of(Hash)
          response.body['1'].should be_kind_of(GarageClient::Resource)
        end
      end
    end
  end

  describe 'delegation' do
    before do
      stub_get('/examples').to_return(fixture('examples.yaml'))
    end

    it 'delegates undefined method call to  resource' do
      response.size.should == 1
      response.first.should be_kind_of(GarageClient::Resource)
    end
  end

  describe 'http errors' do
    {
      400 => GarageClient::BadRequest,
      401 => GarageClient::Unauthorized,
      403 => GarageClient::Forbidden,
      404 => GarageClient::NotFound,
      406 => GarageClient::NotAcceptable,
      409 => GarageClient::Conflict,
      415 => GarageClient::UnsupportedMediaType,
      422 => GarageClient::UnprocessableEntity,
      500 => GarageClient::InternalServerError,
      503 => GarageClient::ServiceUnavailable,
      504 => GarageClient::GatewayTimeout,

      402 => GarageClient::ClientError,
      405 => GarageClient::ClientError,
      407 => GarageClient::ClientError,
      408 => GarageClient::ClientError,
      502 => GarageClient::ServerError,
    }.each do |status, exception|
      context "when HTTP status is #{status}" do
        before do
          stub_get('/examples/xyz').to_return(:status => status)
        end

        it "should raise #{exception.name} error" do
          expect {
            client.get('/examples/xyz')
          }.to raise_error(exception) { |e|
            e.should be_a_kind_of(GarageClient::Error)
            e.response.should be_respond_to(:[])
          }
        end
      end
    end
  end

  describe 'response type error' do
    before do
      stub_get('/examples').to_return(body: 'error')
    end

    it 'raises error' do
      expect { client.get('/examples') }.to raise_error(GarageClient::InvalidResponseType) {|e|
        e.should be_a_kind_of(GarageClient::Error)
      }
    end
  end
end
