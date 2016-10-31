module CopperEgg
  module APM
    module RestClient
      module Request
        def execute_with_ce_instrumentation(&block)
          if CopperEgg::APM::Configuration.benchmark_http?
            result = nil
            time = Benchmark.realtime do
              result = execute_without_ce_instrumentation(&block)
            end

            CopperEgg::APM.send_payload(
              type: :net,
              value: url.gsub(%r{//[^:]+:[^@]@}, "//").gsub(/\?.*/, ""),
              time: time
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
      alias_method :execute_without_ce_instrumentation, :execute
      alias_method :execute, :execute_with_ce_instrumentation
    end
  end

end
