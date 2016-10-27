module CopperEgg
  module APM
    module SQLite3
      module Database
        def execute_with_ce_instrumentation(sql, bind_vars = [], *args, &block)
          if CopperEgg::APM::Configuration.benchmark_sql?
            starttime = Time.now
            result = execute_without_ce_instrumentation(sql, bind_vars, *args, &block)
            time = Time.now - starttime

            return result if sql =~ /\A\s*(begin|commit|rollback|set)/i

            CopperEgg::APM.send_payload(:sql => CopperEgg::APM.obfuscate_sql(sql), :time => time)

            result
          else
            execute_without_ce_instrumentation(sql, bind_vars, *args, &block)
          end
        end
      end
    end
  end
end

if defined?(::SQLite3::Database)

  module SQLite3
    class Database
      include CopperEgg::APM::SQLite3::Database
      alias_method :execute_without_ce_instrumentation, :execute
      alias_method :execute, :execute_with_ce_instrumentation
    end
  end

end
