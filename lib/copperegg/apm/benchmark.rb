require "socket"
require "json"
require "benchmark"

module CopperEgg
  module APM
    DO_NOT_INCLUDE_PATHS = %w(. test spec vendor config)
    PAYLOAD_FREQUENCY = 15
    PAYLOAD_BYTESIZE = 1024*8
    @@benchmarkable_methods = []
    @@payload_sent_at = 0
    @@payload_cache = ""
    @@gem_version_sent = false

    module_function

    def configure(&block)
      Configuration.configure(&block)
      @@payload_cache = {
        version: GEM_VERSION,
        id: Configuration.instrument_key,
        sql: Configuration.benchmark_sql?,
        http: Configuration.benchmark_http?,
        exceptions: Configuration.benchmark_exceptions?,
        methods: Configuration.benchmark_methods_level
      }.to_json
      send_payload_cache
    end

    def benchmark(arg, &block)
      if arg.class == Hash
        parameters = arg
      elsif arg.class == Class || arg.class == Module
        parameters = { type: :method, value: "#{arg}.#{calling_method}" }
      else
        parameters = { type: :method, value: "#{arg.class}##{calling_method}" }
      end

      result = nil
      time = Benchmark.realtime do
        result = yield
      end
      parameters[:time] = time

      send_payload(parameters)

      result
    end

    # Inject benchmarking code into user-defined public instance and class accessor methods whose names are made up of only alphanumeric characters.
    # By user-defined, we mean those whose source is defined in neither the load path nor the gem path.
    def add_method_benchmarking
      benchmarkable_methods.each { |method| method.add_benchmarking unless method.excluded? }
    end

    # Returns an array of unbound methods to which benchmarking can be added.
    def benchmarkable_methods
      return @@benchmarkable_methods if @@benchmarkable_methods.size > 0

      if defined?(::Rails) && Rails.respond_to?(:configuration)
        $LOAD_PATH.each do |path|
          v, $VERBOSE = $VERBOSE, nil
          if path.include?(Rails.configuration.root.to_s) &&
            DO_NOT_INCLUDE_PATHS.detect { |part| path.include?("/#{part}") }.nil?
            Dir.glob("#{path}/**/*.rb").each do
              |f| ActiveSupport::Dependencies::Loadable.require_dependency f, ""
            end
          end
          $VERBOSE = v
        end
      end

      ObjectSpace.each_object(Class) do |class_or_module|
        begin
          class_or_module.instance_methods(false).each do |name|
            method = class_or_module.instance_method(name)
            method.parent_class = class_or_module
            @@benchmarkable_methods.push(method) if method.benchmarkable?
          end
        rescue
        end

        begin
          class_or_module.singleton_class.instance_methods(false).each do |name|
            method = class_or_module.singleton_class.instance_method(name)
            method.parent_class = class_or_module
            method.class_method = true
            @@benchmarkable_methods.push(method) if method.benchmarkable?
          end
        rescue
        end
      end

      @@benchmarkable_methods
    end

    def send_payload(parameters)
      return if CopperEgg::APM::Configuration.instrument_key == nil

      parameters[:stacktrace] = trim_stacktrace(caller)

      json = parameters.to_json
      payload = "#{[0x6375].pack("N")}#{[json.length].pack("N")}#{json}"
      if @@payload_cache.bytesize > PAYLOAD_BYTESIZE
        @@payload_cache = ""
      elsif @@payload_cache.bytesize > 0 && ((@@payload_cache.bytesize + payload.bytesize) >= PAYLOAD_BYTESIZE || Time.now.to_i - @@payload_sent_at >= PAYLOAD_FREQUENCY)
        send_payload_cache
      end
      @@payload_cache = "#{@@payload_cache}#{payload}"
    end

    def send_payload_cache
      begin
        if RUBY_VERSION < "1.9"
          socket = UDPSocket.new
          socket.send(@@payload_cache, 0, CopperEgg::APM::Configuration.udp_host, CopperEgg::APM::Configuration.udp_port)
        else
          socket = Socket.new(:INET, :DGRAM)
          addr = Socket.sockaddr_in(CopperEgg::APM::Configuration.udp_port, CopperEgg::APM::Configuration.udp_host)
          socket.connect_nonblock(addr)
          socket.send(@@payload_cache, 0)
        end
      rescue Errno::EMSGSIZE
      end
      socket.close
      CopperEgg::APM::Configuration.log @@payload_cache
      @@payload_sent_at = Time.now.to_i
      @@payload_cache = ""
    end

    # Returns a copy of self with escaping, quotes, whitespacing and actual values removed
    # from SQL statements
    def obfuscate_sql(sql)
      return sql if sql.bytesize > 1024 # don't bother with sql statements larger than 1k
      sql = sql.dup

      # Remove escaping quotes
      sql.gsub!(/\\["']/, "")

      # Remove surrounding backticks
      sql.gsub!(/[`]([^`]+)[`]/i, '\1')

      # Remove surrounding quotes from strings immediately following "FROM"
      sql.gsub!(/(from|into|update|set)\s*['"`]([^'"`]+)['"`]/i, '\1 \2')

      # Remove surrounding quotes from strings immediately neighboring a period
      sql.gsub!(/([\.])['"]([^'"]+)['"]/, '\1\2')
      sql.gsub!(/['"]([^'"]+)['"]([\.])/, '\1\2')

      # Replace other quoted strings with a question mark
      sql.gsub!(/['"]([^'"]+)['"]/, "?")

      # Remove integers
      sql.gsub!(/\b\d+\b/, "?")

      # Removing padded spaces
      sql.gsub!(/(\s){2,}/, '\1')

      # Remove leading and trailing whitespace
      sql.strip!

      sql
    end

    def trim_stacktrace(array)
      previous_components = nil

      last = array.last.strip

      array.reject! { |path| path.include? CopperEgg::APM::Configuration.gem_root }

      if !CopperEgg::APM::Configuration.app_root.empty?
        array.reject! do |path|
          !path.include?(CopperEgg::APM::Configuration.app_root) ||
            !CopperEgg::APM::DO_NOT_INCLUDE_PATHS.detect { |part| path.include?("/#{part}") }.nil?
        end
      end

      array.map! do |path|
        if previous_components
          current_components = path.split("/")

          if (current_components - previous_components).size == 1
            path = ".../" + (current_components - previous_components).join("/")
          end

          previous_components = current_components
        else
          previous_components = path.split("/")
        end
        path.strip
      end

      array.push(last) if last && array.empty?
      array
    end

    def calling_method
      caller[1] =~ /`([^']*)'/ and $1
    end

    def capture_exception(*args)
      exception = if args.size == 0
        $!.nil? ? RuntimeError.new : $!
      elsif args.size == 1
        args.first.is_a?(String) ? RuntimeError.exception(args.first) : args.first.exception
      elsif args.size <= 3
        args.first.exception(args[1])
      end
      stacktrace = trim_stacktrace(caller)
      parameters = {
        type: :error,
        value: "#{exception.class}|#{stacktrace.first}",
        stacktrace: "#{exception.message}\n#{stacktrace.join("\n")}",
        time: Time.now.to_i
      }
      send_payload(parameters)
    end
  end
end
