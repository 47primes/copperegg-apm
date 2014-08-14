require File.dirname(__FILE__) + '/helpers/mysql2_setup'
require 'spec_helper'

describe Mysql2::Client do
  describe "#query" do
    before do
      @client = Mysql2::Client.new :host => "localhost", :database => "copperegg_apm_test", :username => ENV["MYSQL_USER"]
    end

    it "should benchmark time" do
      result = @client.query "select * from users"
      expect(result).to be_an_instance_of(Mysql2::Result)

      last_payload = CopperEgg::APM.send(:class_variable_get, :@@payload_cache).split("\x00").select {|i| i.size > 2}.map {|i| i.sub(/^[^\{]+/,'')}.last
      hash = JSON.parse last_payload
      
      expect(hash.keys.sort).to eq ["id", "inst"]
      expect(hash["id"]).to match(/\A[0-1a-z]{16}\z/i)
      expect(hash["inst"].keys.sort).to eq ["sql", "time"]
      expect(hash["inst"]["sql"]).to eq "select * from users {Ruby}"
      expect(hash["inst"]["time"].to_s).to match(/\A\d+\Z/)
    end

    it "should benchmark update statements" do
      @client.query "update users set details = 'blah' where id = 1"

      last_payload = CopperEgg::APM.send(:class_variable_get, :@@payload_cache).split("\x00").select {|i| i.size > 2}.map {|i| i.sub(/^[^\{]+/,'')}.last
      hash = JSON.parse last_payload
      
      expect(hash.keys.sort).to eq ["id", "inst"]
      expect(hash["id"]).to match(/\A[0-1a-z]{16}\z/i)
      expect(hash["inst"].keys.sort).to eq ["sql", "time"]
      expect(hash["inst"]["sql"]).to eq "update users set details = ? where id = ? {Ruby}"
      expect(hash["inst"]["time"].to_s).to match(/\A\d+\Z/)
    end    

    it "should not benchmark transaction statements" do
      payload = CopperEgg::APM.send(:class_variable_get, :@@payload_cache)

      @client.query "begin"

      expect(CopperEgg::APM.send(:class_variable_get, :@@payload_cache)).to eq payload

      @client.query "select * from users"

      last_payload = CopperEgg::APM.send(:class_variable_get, :@@payload_cache).split("\x00").select {|i| i.size > 2}.map {|i| i.sub(/^[^\{]+/,'')}.last
      hash = JSON.parse last_payload

      expect(hash["inst"]["sql"]).to eq "select * from users {Ruby}"

      @client.query "commit"

      final_payload = CopperEgg::APM.send(:class_variable_get, :@@payload_cache).split("\x00").select {|i| i.size > 2}.map {|i| i.sub(/^[^\{]+/,'')}.last

      expect(final_payload).to eq last_payload
    end
  end
end
