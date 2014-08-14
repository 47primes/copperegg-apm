#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../spec/helpers/mysql2_setup'
require 'copperegg/apm'
require 'benchmark'

CopperEgg::APM.configure do |config|
  config.instrument_key = "key"
  config.benchmark_sql = false
end

client = Mysql2::Client.new :host => "localhost", :database => "copperegg_apm_test", :username => ENV["MYSQL_USER"]
sql = "UPDATE `users` SET `details` = '512.777.9311', `updated_at` = '#{Time.now.strftime('%Y-%m-%d %H:%M%S')}' WHERE `users`.`id` = 1"
n = 10000

puts "\nFor \"#{sql}\"\n\n"

Benchmark.bm(31) do |x|
  x.report("#{n} queries w/o instrumentation") { n.times { client.query(sql) } }
end

puts

CopperEgg::APM.configure do |config|
  config.instrument_key = "key"
  config.benchmark_sql = true
end

Benchmark.bm(31) do |x|
  x.report("#{n} queries w/ sql obfuscation") { n.times { client.query(sql) } }
end

puts

# class String
#   def bytesize
#     1025
#   end
# end

Benchmark.bm(31) do |x|
  x.report("#{n} queries w/o sql obfuscation") { n.times { client.query(sql) } }
end

puts