require File.dirname(__FILE__) + '/helpers/mysql_setup'
require 'spec_helper'

describe Mysql do
  describe "#query" do
    before do
      @client = Mysql.new("localhost", ENV["MYSQL_USER"], "", "copperegg_apm_test")
    end

    it "should benchmark time" do
      result = @client.query("select * from users")
      expect(result).to be_an_instance_of(Mysql::Result)

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

  describe "#query (with block)" do
    before do
      @client = Mysql.new("localhost", ENV["MYSQL_USER"] || "root", "", "copperegg_apm_test")
    end

    it "should benchmark time" do
      @client.query("select * from users") do |result|
        expect(result).to be_an_instance_of(Mysql::Result)
      end

      last_payload = CopperEgg::APM.send(:class_variable_get, :@@payload_cache).split("\x00").select {|i| i.size > 2}.map {|i| i.sub(/^[^\{]+/,'')}.last
      hash = JSON.parse last_payload
      
      expect(hash.keys.sort).to eq ["id", "inst"]
      expect(hash["id"]).to match(/\A[0-1a-z]{16}\z/i)
      expect(hash["inst"].keys.sort).to eq ["sql", "time"]
      expect(hash["inst"]["sql"]).to eq "select * from users {Ruby}"
      expect(hash["inst"]["time"].to_s).to match(/\A\d+\Z/)
    end
  end
end
