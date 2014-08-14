module CopperEgg
  module APM
    module Rum
      def real_user_monitoring_javascript_tag
        script = %Q(
        <script type="text/javascript">
        var BACON = BACON || {};

        BACON.id = '#{CopperEgg::APM::Configuration.instrument_key}';
        BACON.short_url = #{CopperEgg::APM::Configuration.rum_short_url};
        BACON.beaconUrl = '#{CopperEgg::APM::Configuration.rum_beacon_url}';

        BACON.starttime = new Date().getTime();
        (function(d, s) { var js = d.createElement(s);
            js.async = true; js.src = "http://cdn.copperegg.com/rum/bacon.min.js";
            var s = d.getElementsByTagName(s)[0]; s.parentNode.insertBefore(js, s);
        })(document, "script");
        </script>
        )
        script.respond_to?(:html_safe) ? script.html_safe : script
      end
    end
  end
end