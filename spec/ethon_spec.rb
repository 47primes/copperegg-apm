require 'spec_helper'

describe Ethon::Easy::Operations do
  describe "#perform" do
    it "should benchmark time for a get request" do
      easy = Ethon::Easy.new(:url => "https://api.twitter.com/1.1/help/configuration.json")
      easy.perform

      expect(easy.response_code.to_s).to match(/\A\d{3}\Z/)
      JSON.parse(easy.response_body)

      last_payload = CopperEgg::APM.send(:class_variable_get, :@@payload_cache).split("\x00").select {|i| i.size > 2}.map {|i| i.sub(/^[^\{]+/,'')}.last
      hash = JSON.parse last_payload
      
      expect(hash.keys.sort).to eq ["id", "inst"]
      expect(hash["id"]).to match(/\A[0-1a-z]{16}\z/i)
      expect(hash["inst"].keys.sort).to eq ["time", "url"]
      expect(hash["inst"]["url"]).to eq "https://api.twitter.com/1.1/help/configuration.json {Ruby}"
      expect(hash["inst"]["time"].to_s).to match(/\A\d+\Z/)
    end

    it "should not have authentication nor query params in the url" do
      easy = Ethon::Easy.new
      easy.http_request("http://mikeapikey:U@api.rails.dev/v2/revealmetrics/metric_groups.json?show_hidden=true", :get)
      easy.perform

      expect(easy.response_code.to_s).to match(/\A\d{3}\Z/)

      last_payload = CopperEgg::APM.send(:class_variable_get, :@@payload_cache).split("\x00").select {|i| i.size > 2}.map {|i| i.sub(/^[^\{]+/,'')}.last
      hash = JSON.parse last_payload
      
      expect(hash.keys.sort).to eq ["id", "inst"]
      expect(hash["id"]).to match(/\A[0-1a-z]{16}\z/i)
      expect(hash["inst"].keys.sort).to eq ["time", "url"]
      expect(hash["inst"]["url"]).to eq "http://api.rails.dev/v2/revealmetrics/metric_groups.json {Ruby}"
      expect(hash["inst"]["time"].to_s).to match(/\A\d+\Z/)
    end

    it "should benchmark time for a post request" do
      easy = Ethon::Easy.new
      easy.http_request("http://mikeapikey:U@api.rails.dev/v2/revealmetrics/tags.json", :post, {:params => {:tag => "asjasfe", :ids => "smtp"}})
      easy.perform

      expect(easy.response_code.to_s).to match(/\A\d{3}\Z/)

      last_payload = CopperEgg::APM.send(:class_variable_get, :@@payload_cache).split("\x00").select {|i| i.size > 2}.map {|i| i.sub(/^[^\{]+/,'')}.last
      hash = JSON.parse last_payload
      
      expect(hash.keys.sort).to eq ["id", "inst"]
      expect(hash["id"]).to match(/\A[0-1a-z]{16}\z/i)
      expect(hash["inst"].keys.sort).to eq ["time", "url"]
      expect(hash["inst"]["url"]).to eq "http://api.rails.dev/v2/revealmetrics/tags.json {Ruby}"
      expect(hash["inst"]["time"].to_s).to match(/\A\d+\Z/)
    end

    it "should benchmark time for a delete request" do
      easy = Ethon::Easy.new
      easy.http_request("http://mikeapikey:U@api.rails.dev/v2/revealmetrics/tags/smtp.json", :delete, {:params => {:ids => "smtp"}})
      easy.perform

      expect(easy.response_code.to_s).to match(/\A\d{3}\Z/)

      last_payload = CopperEgg::APM.send(:class_variable_get, :@@payload_cache).split("\x00").select {|i| i.size > 2}.map {|i| i.sub(/^[^\{]+/,'')}.last
      hash = JSON.parse last_payload
      
      expect(hash.keys.sort).to eq ["id", "inst"]
      expect(hash["id"]).to match(/\A[0-1a-z]{16}\z/i)
      expect(hash["inst"].keys.sort).to eq ["time", "url"]
      expect(hash["inst"]["url"]).to eq "http://api.rails.dev/v2/revealmetrics/tags/smtp.json {Ruby}"
      expect(hash["inst"]["time"].to_s).to match(/\A\d+\Z/)
    end
  end
end
