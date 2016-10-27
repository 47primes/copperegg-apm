module CopperEgg
  module APM
    module RestClient
      module Request
        def execute_with_ce_instrumentation(&block)
          if CopperEgg::APM::Configuration.benchmark_http?
            starttime = Time.now
            result = execute_without_ce_instrumentation(&block)
            time = (Time.now - starttime)*1000

            CopperEgg::APM.send_payload(:url => url.gsub(/\/\/[^:]+:[^@]@/,"//").gsub(/\?.*/,""), :time => time)

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
      alias_method :execute_without_ce_instrumentation, :execute
      alias_method :execute, :execute_with_ce_instrumentation
    end
  end

end
