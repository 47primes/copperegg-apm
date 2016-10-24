module CopperEgg
  module APM
    module Mysql
      def query_with_ce_instrumentation(*args)
        if CopperEgg::APM::Configuration.benchmark_sql?
          starttime = (Time.now.to_f * 1000.0).to_i
          result = query_without_ce_instrumentation(*args)
          time = (Time.now.to_f * 1000.0).to_i - starttime

          return result if args.first =~ /\A\s*(begin|commit|rollback|set)/i

          CopperEgg::APM.send_payload(sql: CopperEgg::APM.obfuscate_sql(args.first), time: time)

          result
        else
          query_without_ce_instrumentation(*args)
        end
      end
    end
  end
end

if defined?(::Mysql)
  class Mysql
    include CopperEgg::APM::Mysql
    alias query_without_ce_instrumentation query
    alias query query_with_ce_instrumentation
  end
end
