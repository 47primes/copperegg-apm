module CopperEgg
  module APM
    module Kernel
      alias raise_without_ce_instrumentation raise

      def raise(*args)
        super(ArgumentError, "wrong number of arguments", caller) if args.size > 3
        if CopperEgg::APM::Configuration.benchmark_exceptions?
          CopperEgg::APM.capture_exception(*args)
        end
        raise_without_ce_instrumentation(*args)
      end

      alias fail raise
    end
  end
end

Object.class_eval do
  include CopperEgg::APM::Kernel
end
