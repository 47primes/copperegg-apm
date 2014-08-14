# -*- encoding : utf-8 -*-
require 'spec_helper'

class String
  include CopperEgg::APM::Rum
end

describe CopperEgg::APM::Rum do
  describe "#copperegg_real_user_monitoring" do
    before do
      CopperEgg::APM::Configuration.rum_short_url = true
    end

    it "should return javascript" do
      javascript = "".real_user_monitoring_javascript_tag

      expect(javascript).to match(/^[\s\n]*<script type="text\/javascript">.*<\/script>[\s\n]*$/m)
      expect(javascript.include?("BACON.id = '#{CopperEgg::APM::Configuration.instrument_key}';")).to be_true
      expect(javascript.include?("BACON.short_url = #{CopperEgg::APM::Configuration.rum_short_url};")).to be_true
      expect(javascript.include?("BACON.beaconUrl = '#{CopperEgg::APM::Configuration.rum_beacon_url}';")).to be_true
    end
  end
end