require 'spec_helper'

describe RestClient::Request do
  describe "#execute" do
    it "should benchmark time for a get request" do
      response = RestClient.get("http://mikeapikey:U@api.rails.dev/v2/revealmetrics/metric_groups.json") {|response, request, result| response }

      expect(response.code.to_s).to match(/\A\d{3}\Z/)
      expect(response.to_str).to be_an_instance_of(String)

      last_payload = CopperEgg::APM.send(:class_variable_get, :@@payload_cache).split("\x00").select {|i| i.size > 2}.map {|i| i.sub(/^[^\{]+/,'')}.last
      hash = JSON.parse last_payload
      
      expect(hash.keys.sort).to eq ["id", "inst"]
      expect(hash["id"]).to match(/\A[0-1a-z]{16}\z/i)
      expect(hash["inst"].keys.sort).to eq ["time", "url"]
      expect(hash["inst"]["url"]).to eq "http://api.rails.dev/v2/revealmetrics/metric_groups.json {Ruby}"
      expect(hash["inst"]["time"].to_s).to match(/\A\d+\Z/)
    end

    it "should not have authentication nor query params in the url" do
      resource = RestClient::Resource.new("http://mikeapikey:U@api.rails.dev/v2/revealmetrics/metric_groups.json?show_hidden=true") {|response, request, result| response }
      response = resource.get

      expect(response.code.to_s).to match(/\A\d{3}\Z/)

      last_payload = CopperEgg::APM.send(:class_variable_get, :@@payload_cache).split("\x00").select {|i| i.size > 2}.map {|i| i.sub(/^[^\{]+/,'')}.last
      hash = JSON.parse last_payload
      
      expect(hash.keys.sort).to eq ["id", "inst"]
      expect(hash["id"]).to match(/\A[0-1a-z]{16}\z/i)
      expect(hash["inst"].keys.sort).to eq ["time", "url"]
      expect(hash["inst"]["url"]).to eq "http://api.rails.dev/v2/revealmetrics/metric_groups.json {Ruby}"
      expect(hash["inst"]["time"].to_s).to match(/\A\d+\Z/)
    end

    it "should benchmark time for a post request" do
      response = RestClient.post("http://mikeapikey:U@api.rails.dev/v2/revealmetrics/tags.json", :tag => "asjasfe", :ids => "smtp") {|response, request, result| response }

      expect(response.code.to_s).to match(/\A\d{3}\Z/)

      last_payload = CopperEgg::APM.send(:class_variable_get, :@@payload_cache).split("\x00").select {|i| i.size > 2}.map {|i| i.sub(/^[^\{]+/,'')}.last
      hash = JSON.parse last_payload
      
      expect(hash.keys.sort).to eq ["id", "inst"]
      expect(hash["id"]).to match(/\A[0-1a-z]{16}\z/i)
      expect(hash["inst"].keys.sort).to eq ["time", "url"]
      expect(hash["inst"]["url"]).to eq "http://api.rails.dev/v2/revealmetrics/tags.json {Ruby}"
      expect(hash["inst"]["time"].to_s).to match(/\A\d+\Z/)
    end

    it "should benchmark time for a delete request" do
      response = RestClient.delete("http://mikeapikey:U@api.rails.dev/v2/revealmetrics/tags/smtp.json", :ids => "smtp") {|response, request, result| response }

      expect(response.code.to_s).to match(/\A\d{3}\Z/)

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
