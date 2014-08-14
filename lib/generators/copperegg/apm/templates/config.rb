CopperEgg::APM.configure do |config|
  config.instrument_key       = "<%= instrument_key %>"
  config.benchmark_sql        = true
  config.benchmark_exceptions = true
  config.benchmark_http       = true
  config.benchmark_methods :disabled # To enable, set to :basic, :moderate, or :full
  # Below are examples of customizing method benchmarking
  # config.benchmark_methods :basic, :exclude => %w(UsersController#new UsersController#edit), :include => %w(User UserRole perform)
  # config.benchmark_methods :custom, %w(User Client index ClientsController#create)
end
