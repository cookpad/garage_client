describe GarageClient::Railtie do
  describe 'initializer' do
    let(:parent_name) { 'Cookpad' }

    before do
      allow(Rails).to receive_message_chain(:application, :class, :parent_name).
        and_return(parent_name)
    end

    context 'when GarageClient.configuration.name is absent' do
      before do
        GarageClient.configuration.name = nil
      end

      it 'sets name by Rails.application.class.parent_name' do
        expect {
          GarageClient::RailsInitializer.set_default_name
        }.to change {
          GarageClient.configuration.options[:name]
        }.from(nil).to(parent_name.underscore)
      end
    end

    context 'when GarageClient.configuration.name is present' do
      let(:name) { 'cookpad2' }

      before do
        GarageClient.configuration.name = name
      end

      it 'does not override name' do
        expect {
          GarageClient::RailsInitializer.set_default_name
        }.to_not change {
          GarageClient.configuration.options[:name]
        }.from(name)
      end
    end
  end
end
