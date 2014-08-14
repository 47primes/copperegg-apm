require 'active_support/all'
require 'action_controller'
require 'action_dispatch'
require 'rspec/rails'

module Rails
  class App
    def env_config; {} end
    def routes
      return @routes if defined?(@routes)
      @routes = ActionDispatch::Routing::RouteSet.new
    end
  end

  def self.application
    @app ||= App.new
  end
end
