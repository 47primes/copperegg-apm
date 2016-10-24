module CopperEgg
  module APM
    module Ethon
      module Easy
        module Operations
          def perform_with_ce_instrumentation
            if CopperEgg::APM::Configuration.benchmark_http?
              x = url.gsub(%r{//[^:]+:[^@]@}, "//").gsub(/\?.*/, "")
              starttime = (Time.now.to_f * 1000.0).to_i
              result = perform_without_ce_instrumentation
              time = (Time.now.to_f * 1000.0).to_i - starttime

              CopperEgg::APM.send_payload(url: x, time: time)

              result
            else
              perform_without_ce_instrumentation
            end
          end
        end
      end
    end
  end
end

if defined?(::Ethon::Easy::Operations)

  module Ethon
    class Easy
      module Operations
        include CopperEgg::APM::Ethon::Easy::Operations
        alias perform_without_ce_instrumentation perform
        alias perform perform_with_ce_instrumentation
      end
    end
  end
end
