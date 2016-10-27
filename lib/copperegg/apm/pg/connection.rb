module CopperEgg
  module APM
    module PG
      module Connection
        def exec_with_ce_instrumentation(*args)
          if CopperEgg::APM::Configuration.benchmark_sql?
            starttime = Time.now
            result = block_given? ? exec_without_ce_instrumentation(*args, &Proc.new) : exec_without_ce_instrumentation(*args)
            time = (Time.now - starttime)*1000

            return result if args.first =~ /\A\s*(begin|commit|rollback|set)/i

            CopperEgg::APM.send_payload(:sql => CopperEgg::APM.obfuscate_sql(args.first), :time => time)

            result
          else
            block_given? ? exec_without_ce_instrumentation(*args, &Proc.new) : exec_without_ce_instrumentation(*args)
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
      alias_method :exec_without_ce_instrumentation, :exec
      alias_method :exec, :exec_with_ce_instrumentation
    end
  end

end
