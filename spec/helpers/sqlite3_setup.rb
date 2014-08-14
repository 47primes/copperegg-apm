require 'sqlite3'
require 'faker'

database = SQLite3::Database.new "copperegg_apm_test.db"

database.execute "DROP TABLE IF EXISTS users"
  
create_table_sql = <<-SQL
  CREATE TABLE IF NOT EXISTS users (
    id MEDIUMINT NOT NULL,
    username VARCHAR(32),
    email VARCHAR(100),
    password VARCHAR(100),
    details TEXT,
    PRIMARY KEY (id)
  );
SQL

database.execute create_table_sql

insert_sql = <<-SQL
  INSERT INTO users (id, username, email, password, details)
  VALUES
SQL

10.times do |i|
  insert_sql << "  (#{i}, '#{Faker::Internet.user_name}', '#{Faker::Internet.email}', '#{Faker::Lorem.characters(16)}', '#{Faker::Lorem.paragraph(2)}')#{"," if i < 9}\n"
end

database.execute insert_sql