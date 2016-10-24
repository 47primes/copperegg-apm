require "logger"
require "date"
require "set"

module CopperEgg
  module APM
    class Configuration
      BENCHMARK_METHOD_LEVELS = [:disabled, :basic, :moderate, :full, :custom].freeze

      def self.udp_port
        @udp_port ||= 28_344
      end

      def self.udp_host
        @udp_host ||= "127.0.0.1"
      end

      def self.rum_beacon_url
        @rum_beacon_url ||= "http://bacon.copperegg.com/bacon.gif"
      end

      def self.gem_root
        @gem_root ||= File.dirname(File.dirname(__FILE__))
      end

      def self.app_root=(path)
        @app_root = path.to_s
      end

      def self.app_root
        @app_root ||= ""
      end

      def self.instrument_key=(key)
        raise(ConfigurationError, "invalid instrument key") if !key =~ /\A[a-z0-9]+\z/i
        @instrument_key = key
        create_logfile if @log_to
      end

      def self.instrument_key
        @instrument_key
      end

      def self.rum_short_url=(boolean)
        if boolean != true && boolean != false
          raise ConfigurationError.new("RUM short url must be a boolean")
        end
        @rum_short_url = boolean
      end

      def self.rum_short_url
        @rum_short_url
      end

      def self.benchmark_sql=(boolean)
        if boolean != true && boolean != false
          raise ConfigurationError, "Boolean expected for benchmark_sql"
        end
        @benchmark_sql = boolean
      end

      def self.benchmark_sql?
        @benchmark_sql ||= true
      end

      def self.benchmark_active_record=(boolean)
        if boolean != true && boolean != false
          raise ConfigurationError, "Boolean expected for benchmark_active_record"
        end
        @benchmark_sql = boolean
      end

      def self.benchmark_active_record?
        @benchmark_active_record ||= false
      end

      def self.benchmark_http=(boolean)
        if boolean != true && boolean != false
          raise ConfigurationError, "Boolean expected for benchmark_http"
        end
        @benchmark_http = boolean
      end

      def self.benchmark_http?
        @benchmark_http ||= true
      end

      def self.benchmark_exceptions=(boolean)
        if boolean != true && boolean != false
          raise ConfigurationError, "Boolean expected for benchmark_exceptions"
        end
        @benchmark_exceptions = boolean
      end

      def self.benchmark_exceptions?
        @benchmark_exceptions ||= true
      end

      def self.benchmark_methods(level, options = {})
        unless BENCHMARK_METHOD_LEVELS.include?(level)
          raise ConfigurationError,
                "Method benchmark level can only be :disabled, :basic, :moderate, :full, or :custom"
        end

        @benchmark_methods_level = level
        return if level == :disabled

        if level == :custom
          benchmark_methods_option(options, :@only_methods)
        else
          benchmark_methods_option(options[:include], :@include_methods) if options[:include]
          benchmark_methods_option(options[:exclude], :@exclude_methods) if options[:exclude]
        end
      end

      def self.benchmark_methods_level
        @benchmark_methods_level ||= :disabled
      end

      def self.only_methods
        @only_methods ||= []
      end

      def self.include_methods
        @include_methods ||= []
      end

      def self.exclude_methods
        @exclude_methods ||= []
      end

      def self.log(payload)
        return if @logger.nil?

        @logger.debug("Payload sent at \
        #{DateTime.strptime(Time.now.to_i.to_s, '%s').strftime('%Y-%m-%d %H:%M:%S')} \
        #{payload.bytesize} bytes\n")
        @logger.debug(
          payload.split("\x00")
          .select { |i| i.size > 2 }
          .map { |i| i.sub(/^[^\{]+/, "") }
          .join("\n")
        )

        @logger.debug ""
      end

      def self.enable_logging(dir = "/tmp")
        if !File.readable?(dir) || !File.writable?(dir)
          raise ConfigurationError, "Directory #{dir} must be readable and writable."
        end
        @log_to = dir
        create_logfile
      end

      def self.disabled?
        @disabled ||= false
      end

      def self.disable
        @disabled = true
      end

      def self.configure(&block)
        yield(self)

        if app_root.empty?
          self.app_root = if defined?(::Rails) && ::Rails.respond_to?(:configuration)
                            ::Rails.configuration.root.to_s
                          else
                            File.dirname(caller[1])
                          end
        end

        if disabled?
          self.benchmark_sql = false
          self.benchmark_active_record = false
          self.benchmark_http = false
          self.benchmark_exceptions = false
          self.benchmark_methods_level   = :disabled
          self.only_methods              = []
          self.exclude_methods           = []
          self.include_methods           = []
        elsif benchmark_methods_level != :disabled
          CopperEgg::APM.add_method_benchmarking
        end
      end

      class <<self
        private

        def benchmark_methods_option(array, class_variable_name)
          unless array.is_a?(Array)
            raise ConfigurationError, "Array expected for benchmark method option"
          end
          array.each do |value|
            unless value.is_a?(String)
              raise ConfigurationError,
              "Invalid item #{value} in benchmark method option. String expected."
            end
          end
          class_variable_set(class_variable_name, array)
        end

        def create_logfile
          logdir = File.join(@log_to, "copperegg", "apm")
          FileUtils.mkdir_p(logdir) unless File.directory?(logdir)
          @logger = Logger.new(File.join(logdir, "apm.log"), 0)
        end
      end
    end
  end
end
