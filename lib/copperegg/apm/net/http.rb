module CopperEgg
  module APM
    module Net
      module HTTP
        def request_with_ce_instrumentation(req, body=nil, &block)
          if CopperEgg::APM::Configuration.benchmark_http?
            starttime = (Time.now.to_f * 1000.0).to_i
            result = request_without_ce_instrumentation(req, body, &block)
            time = (Time.now.to_f * 1000.0).to_i - starttime
            url = "http#{"s" if @use_ssl}://#{address}#{":#{port}" if port != ::Net::HTTP.default_port}#{req.path.sub(/\?.*/,"")}"

            CopperEgg::APM.send_payload(:url => url, :time => time)
              
            result
          else
            request_without_ce_instrumentation(req, body, &block)
          end
        end
      end
    end
  end
end

begin
  require 'net/http'
rescue LoadError
end

if defined?(::Net::HTTP)

  module Net
    class HTTP
      include CopperEgg::APM::Net::HTTP
      alias_method :request_without_ce_instrumentation, :request
      alias_method :request, :request_with_ce_instrumentation
    end
  end

end