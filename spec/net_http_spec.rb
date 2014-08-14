require 'spec_helper'

describe Net::HTTP do
  describe "#request" do
    it "should benchmark time for a get request" do
      uri = URI("http://api.rails.dev/v2/revealmetrics/metric_groups.json")
      request = Net::HTTP::Get.new(uri.request_uri)
      request.basic_auth :mikeapikey, :U
      response = Net::HTTP.start(uri.host, uri.port) {|http| http.request(request)}
  
      expect(response.code).to match(/\A\d{3}\Z/)
      expect(response.body).to be_an_instance_of(String)

      last_payload = CopperEgg::APM.send(:class_variable_get, :@@payload_cache).split("\x00").select {|i| i.size > 2}.map {|i| i.sub(/^[^\{]+/,'')}.last
      hash = JSON.parse last_payload
      
      expect(hash.keys.sort).to eq ["id", "inst"]
      expect(hash["id"]).to match(/\A[0-1a-z]{16}\z/i)
      expect(hash["inst"].keys.sort).to eq ["time", "url"]
      expect(hash["inst"]["url"]).to eq "http://api.rails.dev/v2/revealmetrics/metric_groups.json {Ruby}"
      expect(hash["inst"]["time"].to_s).to match(/\A\d+\Z/)
    end

    it "should not have authentication nor query params in the url" do
      Net::HTTP.get(URI("http://mikeapikey:U@api.rails.dev/v2/revealmetrics/metric_groups.json?show_hidden=true"))

      last_payload = CopperEgg::APM.send(:class_variable_get, :@@payload_cache).split("\x00").select {|i| i.size > 2}.map {|i| i.sub(/^[^\{]+/,'')}.last
      hash = JSON.parse last_payload
      
      expect(hash.keys.sort).to eq ["id", "inst"]
      expect(hash["id"]).to match(/\A[0-1a-z]{16}\z/i)
      expect(hash["inst"].keys.sort).to eq ["time", "url"]
      expect(hash["inst"]["url"]).to eq "http://api.rails.dev/v2/revealmetrics/metric_groups.json {Ruby}"
      expect(hash["inst"]["time"].to_s).to match(/\A\d+\Z/)
    end

    it "should benchmark time for a post request" do
      response = Net::HTTP.post_form URI("http://mikeapikey:U@api.rails.dev/v2/revealmetrics/tags.json"), :tag => "asjasfe", :ids => "smtp"

      expect(response.code).to match(/\A\d{3}\Z/)

      last_payload = CopperEgg::APM.send(:class_variable_get, :@@payload_cache).split("\x00").select {|i| i.size > 2}.map {|i| i.sub(/^[^\{]+/,'')}.last
      hash = JSON.parse last_payload
      
      expect(hash.keys.sort).to eq ["id", "inst"]
      expect(hash["id"]).to match(/\A[0-1a-z]{16}\z/i)
      expect(hash["inst"].keys.sort).to eq ["time", "url"]
      expect(hash["inst"]["url"]).to eq "http://api.rails.dev/v2/revealmetrics/tags.json {Ruby}"
      expect(hash["inst"]["time"].to_s).to match(/\A\d+\Z/)
    end
  end
end
