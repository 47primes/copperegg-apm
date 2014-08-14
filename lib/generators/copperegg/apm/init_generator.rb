module Copperegg
  module Apm
    module Generators
      class InitGenerator < Rails::Generators::Base
        source_root File.expand_path("../templates", __FILE__)
        desc "Creates an initializer file at config/initializers/copperegg_apm_config.rb"

        def create_initializer
          template "config.rb", "#{Rails.root}/config/initializers/copperegg_apm_config.rb", :verbose => true
        end

        private

        def instrument_key
          @instrument_key = ask("Enter your app key:")
        end
      end
    end
  end
end
