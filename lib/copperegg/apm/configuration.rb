require 'logger'
require 'date'
require 'set'

module CopperEgg
  module APM
    class Configuration
      BENCHMARK_METHOD_LEVELS = [:disabled, :basic, :moderate, :full, :custom]

      @@udp_port                  = 28344
      @@udp_host                  = "127.0.0.1"
      @@app_root                  = ""
      @@instrument_key            = nil
      @@rum_short_url             = false
      @@rum_beacon_url            = "http://bacon.copperegg.com/bacon.gif"
      @@gem_root                  = File.dirname(File.dirname(__FILE__))
      @@log_to                    = nil
      @@benchmark_sql             = true
      @@benchmark_active_record   = true
      @@benchmark_http            = true
      @@benchmark_exceptions      = true
      @@benchmark_methods_level   = :disabled
      @@only_methods              = []
      @@exclude_methods           = []
      @@include_methods           = []
      @@logger                    = nil
      @@disabled                  = false

      def self.udp_port
        @@udp_port
      end

      def self.udp_host
        @@udp_host
      end

      def self.rum_beacon_url
        @@rum_beacon_url
      end

      def self.gem_root
        @@gem_root
      end

      def self.instrument_key=(key)
        raise ConfigurationError.new("invalid instrument key") if !key =~ /\A[a-z0-9]+\z/i
        @@instrument_key = key
        create_logfile if @@log_to
      end

      def self.instrument_key
        @@instrument_key
      end

      def self.rum_short_url=(boolean)
        raise ConfigurationError.new("RUM short url must be a boolean") if boolean != true && boolean != false
        @@rum_short_url = boolean
      end

      def self.rum_short_url
        @@rum_short_url
      end

      def self.app_root=(path)
        @@app_root = path.to_s
      end

      def self.app_root
        @@app_root
      end

      def self.benchmark_sql=(boolean)
        raise ConfigurationError.new("Boolean expected for benchmark_sql") if boolean != true && boolean != false
        @@benchmark_sql = boolean
      end

      def self.benchmark_sql?
        @@benchmark_sql
      end

      def self.benchmark_active_record=(boolean)
        raise ConfigurationError.new("Boolean expected for benchmark_active_record") if boolean != true && boolean != false
        @@benchmark_active_record = boolean
      end

      def self.benchmark_active_record?
        @@benchmark_active_record
      end

      def self.benchmark_http=(boolean)
        raise ConfigurationError.new("Boolean expected for benchmark_http") if boolean != true && boolean != false
        @@benchmark_http = boolean
      end

      def self.benchmark_http?
        @@benchmark_http
      end

      def self.benchmark_exceptions=(boolean)
        raise ConfigurationError.new("Boolean expected for benchmark_exceptions") if boolean != true && boolean != false
        @@benchmark_exceptions = boolean
      end

      def self.benchmark_exceptions?
        @@benchmark_exceptions
      end

      def self.benchmark_methods(level, options={})
        raise ConfigurationError.new("Method benchmark level can only be :disabled, :basic, :moderate, :full, or :custom") if !BENCHMARK_METHOD_LEVELS.include?(level)

        @@benchmark_methods_level = level
        return if level == :disabled

        if level == :custom
          benchmark_methods_option(options, :@@only_methods)
        else
          benchmark_methods_option(options[:include], :@@include_methods) if options[:include]
          benchmark_methods_option(options[:exclude], :@@exclude_methods) if options[:exclude]
        end
      end

      def self.benchmark_methods_level
        @@benchmark_methods_level
      end

      def self.only_methods
        @@only_methods || []
      end

      def self.include_methods
        @@include_methods || []
      end

      def self.exclude_methods
        @@exclude_methods || []
      end

      def self.log(payload)
        return if @@logger == nil
        @@logger.debug "Payload sent at #{DateTime.strptime(Time.now.to_i.to_s, '%s').strftime('%Y-%m-%d %H:%M:%S')} #{payload.bytesize} bytes\n"
        @@logger.debug payload.split("\x00").select {|i| i.size > 2}.map {|i| i.sub(/^[^\{]+/,'')}.join("\n")
        @@logger.debug ""
      end

      def self.enable_logging(dir = '/tmp')
        raise ConfigurationError.new("Directory #{dir} must be readable and writable.") if !File.readable?(dir) || !File.writable?(dir)
        @@log_to = dir
        if @@instrument_key
          create_logfile
        end
      end

      def self.disable
        @@disabled = true
      end

      def self.configure(&block)
        yield(self)

        if @@app_root.empty?
          if defined?(::Rails) && ::Rails.respond_to?(:configuration)
            @@app_root = ::Rails.configuration.root.to_s
          else
            @@app_root = File.dirname(caller[1])
          end
        end

        if @@disabled
          @@benchmark_sql = @@benchmark_active_record = @@benchmark_http = @@benchmark_exceptions = false
          @@benchmark_methods_level   = :disabled
          @@only_methods              = []
          @@exclude_methods           = []
          @@include_methods           = []
        elsif @@benchmark_methods_level != :disabled
          CopperEgg::APM.add_method_benchmarking
        end
      end

      class <<self
        private

        def benchmark_methods_option(array, class_variable_name)
          raise ConfigurationError.new("Array expected for benchmark method option") if !array.is_a?(Array)
          array.each do |value|
            raise ConfigurationError.new("Invalid item #{value} in benchmark method option. String expected.") if !value.is_a?(String)
          end
          class_variable_set(class_variable_name, array)
        end

        def create_logfile
          logdir = File.join(@@log_to, 'copperegg', 'apm')
          FileUtils.mkdir_p(logdir) unless File.directory?(logdir)

          @@logger = Logger.new(File.join(logdir, "#{Rails.env}.log"), 0)
        end
      end
    end
  end
end
