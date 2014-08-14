require 'spec_helper'

describe Kernel do
  describe "#raise" do
    it "should instrument any exception" do
      expect { raise "the roof" }.to raise_error(RuntimeError)
      print "."

      last_payload = CopperEgg::APM.send(:class_variable_get, :@@payload_cache).split("\x00").select {|i| i.size > 2}.map {|i| i.sub(/^[^\{]+/,'')}.last
      hash = JSON.parse last_payload
      
      expect(hash.keys.sort).to eq ["excp", "id"]
      expect(hash["id"]).to match(/\A[0-1a-z]{16}\z/i)
      expect(hash["excp"].keys.sort).to eq ["error", "stacktrace", "ts"]
      expect(hash["excp"]["error"]).to match(/RuntimeError\|/)
      expect(hash["excp"]["stacktrace"]).to match(/\Athe roof\n/)
      expect(hash["excp"]["ts"]).to be_an_instance_of(Fixnum)
    end
  end

  describe "#fail" do
    it "should instrument any exception" do      
      expect { fail "epically" }.to raise_error(RuntimeError)
      print "."

      last_payload = CopperEgg::APM.send(:class_variable_get, :@@payload_cache).split("\x00").select {|i| i.size > 2}.map {|i| i.sub(/^[^\{]+/,'')}.last
      hash = JSON.parse last_payload
      
      expect(hash.keys.sort).to eq ["excp", "id"]
      expect(hash["id"]).to match(/\A[0-1a-z]{16}\z/i)
      expect(hash["excp"].keys.sort).to eq ["error", "stacktrace", "ts"]
      expect(hash["excp"]["error"]).to match(/RuntimeError\|/)
      expect(hash["excp"]["stacktrace"]).to match(/\Aepically\n/)
      expect(hash["excp"]["ts"]).to be_an_instance_of(Fixnum)
    end
  end
end
