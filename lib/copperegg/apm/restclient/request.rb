module CopperEgg
  module APM
    module RestClient
      module Request
        def execute_with_ce_instrumentation(&block)
          if CopperEgg::APM::Configuration.benchmark_http?
            starttime = (Time.now.to_f * 1000.0).to_i
            result = execute_without_ce_instrumentation(&block)
            time = (Time.now.to_f * 1000.0).to_i - starttime

            CopperEgg::APM.send_payload(
              url: url.gsub(%r{//[^:]+:[^@]@}, "//").gsub(/\?.*/, ""), time: time
            )

            result
          else
            execute_without_ce_instrumentation(&block)
          end
        end
      end
    end
  end
end

if defined?(::RestClient::Request)
  module RestClient
    class Request
      include CopperEgg::APM::RestClient::Request
      alias execute_without_ce_instrumentation execute
      alias execute execute_with_ce_instrumentation
    end
  end
end
