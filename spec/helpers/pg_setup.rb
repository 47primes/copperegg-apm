require 'pg'
require 'faker'

begin
  connection = PG.connect(:dbname => 'copperegg_apm_test', :user => ENV["PG_USER"])
rescue PG::Error => e
  if e.message =~ /database "copperegg_apm_test" does not exist/
    if ENV["PG_USER"]
      `createdb -U #{ENV["PG_USER"]} -w copperegg_apm_test`
    else
      `createdb -w copperegg_apm_test`
    end
    connection = PG.connect(:dbname => 'copperegg_apm_test', :user => ENV["PG_USER"])
  else
    raise e
  end
end

create_table_sql = <<-SQL
  CREATE TABLE IF NOT EXISTS users (
    username VARCHAR,
    email VARCHAR,
    password VARCHAR,
    details TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
  )
SQL

connection.exec create_table_sql

connection.exec "TRUNCATE users"

insert_sql = <<-SQL
  INSERT INTO users (username, email, password, details, created_at, updated_at)
  VALUES
SQL

10.times do |i|
  insert_sql << "  ('#{Faker::Internet.user_name}', '#{Faker::Internet.email}', '#{Faker::Lorem.characters(16)}', '#{Faker::Lorem.paragraph(2)}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)#{"," if i < 9}\n"
end

connection.exec insert_sql
