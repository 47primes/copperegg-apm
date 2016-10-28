at_exit do
  begin
    CopperEgg::APM.send_payload_cache
  rescue
  end
end

%w(
  benchmark
  active_record/connection_adapters/abstract_adapter
  configuration
  errors
  ethon/easy/operations
  kernel
  mysql
  mysql2/client
  net/http
  pg/connection
  restclient/request
  rum
  sqlite3/database
  typhoeus/hydra
  unbound_method
  version
).each { |file| require "copperegg/apm/#{file}" }

require 'copperegg/apm/engine' if defined?(::Rails::Engine)
