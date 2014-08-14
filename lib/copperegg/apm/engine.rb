module CopperEgg
  module APM
    class Engine < ::Rails::Engine
      initializer "copperegg_apm.helpers" do
        ActiveSupport.on_load_all do
          helper CopperEgg::APM::Rum
        end
      end
      
      rake_tasks do
        load 'copperegg/apm/tasks.rb'
      end
    end
  end
end
