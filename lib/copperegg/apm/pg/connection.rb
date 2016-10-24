module CopperEgg
  module APM
    module PG
      module Connection
        def exec_with_ce_instrumentation(*args)
          if CopperEgg::APM::Configuration.benchmark_sql?
            starttime = (Time.now.to_f * 1000.0).to_i
            result = if block_given?
                       exec_without_ce_instrumentation(*args, &Proc.new)
                     else
                       exec_without_ce_instrumentation(*args)
                     end
            time = (Time.now.to_f * 1000.0).to_i - starttime

            return result if args.first =~ /\A\s*(begin|commit|rollback|set)/i

            CopperEgg::APM.send_payload(sql: CopperEgg::APM.obfuscate_sql(args.first), time: time)

            result
          elsif block_given?
            exec_without_ce_instrumentation(*args, &Proc.new)
          else
            exec_without_ce_instrumentation(*args)
          end
        end
      end
    end
  end
end

if defined?(::PG::Connection)
  module PG
    class Connection
      include CopperEgg::APM::PG::Connection
      alias exec_without_ce_instrumentation exec
      alias exec exec_with_ce_instrumentation
    end
  end
end
