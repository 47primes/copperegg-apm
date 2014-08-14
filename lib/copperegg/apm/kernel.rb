module CopperEgg
  module APM
    module Kernel
      alias_method :raise_without_ce_instrumentation, :raise

      def raise(*args)
        super(ArgumentError, "wrong number of arguments", caller) if args.size > 3
        CopperEgg::APM.capture_exception(*args) if CopperEgg::APM::Configuration.benchmark_exceptions?
        raise_without_ce_instrumentation(*args)
      end
      
      alias_method :fail, :raise
    end
  end
end

Object.class_eval do
  include CopperEgg::APM::Kernel
end