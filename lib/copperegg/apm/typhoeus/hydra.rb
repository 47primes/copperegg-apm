module CopperEgg
  module APM
    module Typhoeus
      module Hydra
        def handle_request_with_ce_instrumentation(request, response, live_request=true)
          if CopperEgg::APM::Configuration.benchmark_http?
            starttime = Time.now
            result = handle_request_without_ce_instrumentation(request, response, live_request)
            time = (Time.now.to_f - starttime)*1000

            CopperEgg::APM.send_payload(:url => request.url.gsub(/\/\/[^:]+:[^@]@/,"//").gsub(/\?.*/,""), :time => time)

            result
          else
            handle_request_without_ce_instrumentation(request, response, live_request)
          end
        end
      end
    end
  end
end

if defined?(::Typhoeus::Hydra) && defined?(::Typhoeus::VERSION) && ::Typhoeus::VERSION =~ /\A0\.3\.?/

  module Typhoeus
    class Hydra
      include CopperEgg::APM::Typhoeus::Hydra
      alias_method :handle_request_without_ce_instrumentation, :handle_request
      alias_method :handle_request, :handle_request_with_ce_instrumentation
    end
  end

end
