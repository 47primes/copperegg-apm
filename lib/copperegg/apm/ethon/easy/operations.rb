module CopperEgg
  module APM
    module Ethon
      module Easy
        module Operations
          def perform_with_ce_instrumentation
            if CopperEgg::APM::Configuration.benchmark_http?
              x = url.gsub(/\/\/[^:]+:[^@]@/,"//").gsub(/\?.*/,"")
              starttime = Time.now
              result = perform_without_ce_instrumentation
              time = Time.now - starttime

              CopperEgg::APM.send_payload(type: :net, value: x, time: time)

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
        alias_method :perform_without_ce_instrumentation, :perform
        alias_method :perform, :perform_with_ce_instrumentation
      end
    end
  end
end
