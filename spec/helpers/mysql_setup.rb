require 'mysql'
require 'faker'

begin
  connection = Mysql.new("localhost", ENV["MYSQL_USER"])

  create_db_sql = <<-SQL
    CREATE DATABASE IF NOT EXISTS copperegg_apm_test
    DEFAULT CHARACTER SET = utf8
  SQL
  
  connection.query create_db_sql
  connection.query "GRANT ALL PRIVILEGES ON copperegg_apm_test.* TO '%'@'%'"
  connection.query "USE copperegg_apm_test"

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

  connection.query create_table_sql

  connection.query "TRUNCATE users"

  insert_sql = <<-SQL
    INSERT INTO users (username, email, password, details, created_at, updated_at)
    VALUES
  SQL

  10.times do |i|
    insert_sql << "  ('#{Faker::Internet.user_name}', '#{Faker::Internet.email}', '#{Faker::Lorem.characters(16)}', '#{Faker::Lorem.paragraph(2)}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)#{"," if i < 9}\n"
  end

  connection.query insert_sql
rescue Mysql::Error => e
  puts "Could not create database copperegg_apm_test using user set in ENV['MYSQL_USER']. #{e.message}."
end
