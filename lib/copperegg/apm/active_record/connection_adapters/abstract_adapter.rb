module CopperEgg
  module APM
    module ActiveRecord
      module ConnectionAdapters
        module AbstractAdapter
          def log_with_ce_instrumentation(*args)
            if CopperEgg::APM::Configuration.benchmark_active_record?
              sql, = args
              starttime = (Time.now.to_f * 1000.0).to_i
              result = if block_given?
                         log_without_ce_instrumentation(*args, &Proc.new)
                       else
                         log_without_ce_instrumentation(*args)
                       end
              time = (Time.now.to_f * 1000.0).to_i - starttime

              CopperEgg::APM.send_payload(sql: CopperEgg::APM.obfuscate_sql(sql), time: time)

              result
            else
              if block_given?
                log_without_ce_instrumentation(*args, &Proc.new)
              else
                log_without_ce_instrumentation(*args)
              end
            end
          end
        end
      end
    end
  end
end

if defined?(::ActiveRecord) && ::ActiveRecord::VERSION::MAJOR >= 3
  module ActiveRecord
    module ConnectionAdapters
      class AbstractAdapter
        include CopperEgg::APM::ActiveRecord::ConnectionAdapters::AbstractAdapter
        alias log_without_ce_instrumentation log
        alias log log_with_ce_instrumentation
        protected :log
      end
    end
  end
end
