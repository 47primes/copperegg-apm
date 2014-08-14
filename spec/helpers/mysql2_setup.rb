begin
  require 'mysql2'
  require 'faker'
rescue LoadError
  require 'rubygems'
  require 'mysql2'
  require 'faker'
end

begin
  client = Mysql2::Client.new :host => "localhost", :username => ENV["MYSQL_USER"]

  create_db_sql = <<-SQL
    CREATE DATABASE IF NOT EXISTS copperegg_apm_test
    DEFAULT CHARACTER SET = utf8
  SQL

  client.query create_db_sql
  client.query "GRANT ALL PRIVILEGES ON copperegg_apm_test.* TO '%'@'%'"
  client.query "USE copperegg_apm_test"

  create_table_sql = <<-SQL
    CREATE TABLE IF NOT EXISTS users (
      id MEDIUMINT NOT NULL AUTO_INCREMENT,
      username VARCHAR(32),
      email VARCHAR(100),
      password VARCHAR(100),
      details TEXT,
      created_at TIMESTAMP,
      updated_at TIMESTAMP,
      PRIMARY KEY (id)
    ) DEFAULT CHARSET = utf8
  SQL

  client.query create_table_sql

  client.query "TRUNCATE users"

  insert_sql = <<-SQL
    INSERT INTO users (username, email, password, details, created_at, updated_at)
    VALUES
  SQL

  10.times do |i|
    insert_sql << "  ('#{Faker::Internet.user_name}', '#{Faker::Internet.email}', '#{Faker::Lorem.characters(16)}', '#{Faker::Lorem.paragraph(2)}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)#{"," if i < 9}\n"
  end

  client.query insert_sql
rescue Exception => e
  puts "Could not create database copperegg_apm_test using user set in ENV['MYSQL_USER']. #{e.message}."
end
