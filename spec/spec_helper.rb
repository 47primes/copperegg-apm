require 'mysql'
require 'mysql2'
require 'pg'
require 'sqlite3'
require 'typhoeus'
require 'ethon'
require 'rest-client'
require 'copperegg/apm'

CopperEgg::APM.configure do |config|
  config.instrument_key = 16.times.reduce("") { |memo, i| memo << "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"[rand(16)].chr; memo }
end