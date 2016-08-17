module GarageClient
  class Railtie < ::Rails::Railtie
    initializer :garage_client do |app|
      RailsInitializer.set_default_name
    end
  end

  module RailsInitializer
    def self.set_default_name
      unless GarageClient.configuration.options[:name]
        GarageClient.configure do |c|
          c.name = ::Rails.application.class.parent_name.underscore
        end
      end
    end
  end
end
