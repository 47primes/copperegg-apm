require File.dirname(__FILE__) + '/helpers/sqlite3_setup'
require 'spec_helper'

describe SQLite3::Database do
  describe "#execute" do
    before(:each) do
      @database = SQLite3::Database.new "copperegg_apm_test.db"
    end

    it "should benchmark time" do
      result = @database.execute "select * from users"
      expect(result).to be_an_instance_of(Array)

      last_payload = CopperEgg::APM.send(:class_variable_get, :@@payload_cache).split("\x00").select {|i| i.size > 2}.map {|i| i.sub(/^[^\{]+/,'')}.last
      hash = JSON.parse last_payload
      
      expect(hash.keys.sort).to eq ["id", "inst"]
      expect(hash["id"]).to match(/\A[0-1a-z]{16}\z/i)
      expect(hash["inst"].keys.sort).to eq ["sql", "time"]
      expect(hash["inst"]["sql"]).to eq "select * from users {Ruby}"
      expect(hash["inst"]["time"].to_s).to match(/\A\d+\Z/)
    end

    it "should not benchmark transaction statements" do
      payload = CopperEgg::APM.send(:class_variable_get, :@@payload_cache)

      @database.execute "begin"

      expect(CopperEgg::APM.send(:class_variable_get, :@@payload_cache)).to eq payload

      @database.execute "select * from users"

      last_payload = CopperEgg::APM.send(:class_variable_get, :@@payload_cache).split("\x00").select {|i| i.size > 2}.map {|i| i.sub(/^[^\{]+/,'')}.last
      hash = JSON.parse last_payload

      expect(hash["inst"]["sql"]).to eq "select * from users {Ruby}"

      @database.execute "commit"

      final_payload = CopperEgg::APM.send(:class_variable_get, :@@payload_cache).split("\x00").select {|i| i.size > 2}.map {|i| i.sub(/^[^\{]+/,'')}.last

      expect(final_payload).to eq last_payload
    end
  end
end
