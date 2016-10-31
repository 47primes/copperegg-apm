module CopperEgg
  module APM
    module Mysql2
      module Client
        def query_with_ce_instrumentation(*args)
          if CopperEgg::APM::Configuration.benchmark_sql?
            result = nil
            time = Benchmark.realtime do
              result = query_without_ce_instrumentation(*args)
            end

            return result if args.first =~ /\A\s*(begin|commit|rollback|set)/i

            CopperEgg::APM.send_payload(
              type: :sql,
              value: CopperEgg::APM.obfuscate_sql(args.first),
              time: time
            )

            result
          else
            query_without_ce_instrumentation(*args)
          end
        end
      end
    end
  end
end

if defined?(::Mysql2::Client)

  module Mysql2
    class Client
      include CopperEgg::APM::Mysql2::Client
      alias_method :query_without_ce_instrumentation, :query
      alias_method :query, :query_with_ce_instrumentation
    end
  end

end
