require 'spec_helper'

describe GarageClient::Resource do
  let(:client) { GarageClient::Client.new }
  let(:response_body) { JSON.parse(fixture('example.yaml')['body']) }
  let(:resource) { GarageClient::Resource.new(client, response_body) }

  describe '#properties' do
    it 'returns available properties' do
      resource.properties.should include(
        :id,
        :created,
        :updated,
        :name,
        :url,
        :description,
        :serving,
        :published,
        :edited,
        :tier,
        :ingredients,
        :steps
      )
    end
  end

  describe '#links' do
    it 'returns available links' do
      resource.links.should include(:self, :canonical, :nested_examples)
    end
  end

  describe '#update' do
    before do
      stub_put('/examples/1').to_return(fixture('example.yaml'))
    end

    it 'returns response with updated resource' do
      response = resource.update(:name => 'new name')
      response.should be_kind_of(GarageClient::Response)
      response.body.should be_kind_of(GarageClient::Resource)
    end
  end

  describe '#destroy' do
    before do
      stub_delete('/examples/1').to_return(:status => 204, :body => '')
    end

    it 'returns response' do
      response = resource.destroy
      response.should be_kind_of(GarageClient::Response)
      response.body.should be_nil
    end
  end

  describe 'create nested resource' do
    before do
      stub_post('/examples/1/nested_examples').to_return(fixture('example.yaml'))
    end

    it 'returns response' do
      response = resource.create_nested_examples(:name => 'name')
      response.should be_kind_of(GarageClient::Response)
      response.body.should be_kind_of(GarageClient::Resource)
    end
  end

  describe 'property' do
    context 'with non-existent property' do
      it 'raise no method error' do
        expect { resource.non_existent_field }.to raise_error(NoMethodError)
      end
    end

    context 'with primitive value' do
      it 'returns value' do
        resource.name.should == 'recipe title'
      end
    end

    context 'with resource value' do
      it 'returns resource' do
        resource.user.should be_kind_of(GarageClient::Resource)
      end
    end
  end

  describe 'link' do
    context 'with existent link' do
      before do
        stub_get('/examples/1/nested_examples').to_return(fixture('examples.yaml'))
      end

      it 'returns response' do
        response = resource.nested_examples
        response.should be_kind_of(GarageClient::Response)
        response.body.should be_kind_of(Array)
      end
    end
  end
end
