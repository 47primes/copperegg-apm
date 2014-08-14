module CopperEgg
  module APM
    class BenchmarkMethodsTable
      def benchmarkable_methods
        @benchmarkable_methods ||= CopperEgg::APM.benchmarkable_methods.sort_by(&:display_name)
      end

      def excluded_methods
        benchmarkable_methods.select {|method| method.excluded?}
      end

      def method_column_width
        benchmarkable_methods.reduce(0) do |memo, method|
          method.display_name.size > memo ? method.display_name.size : memo
        end + column_padding
      end

      def source_filename_column_width
        benchmarkable_methods.reduce(0) do |memo, method|
          method.display_filename.size > memo ? method.display_filename.size : memo
        end + column_padding
      end

      def column_padding
        2
      end

      def separator
        "+" + "-"*(method_column_width+1) + "+" + "-"*(source_filename_column_width+1) + "+" + "--------------+"
      end

      def header_columns
        "| Method" + " "*(method_column_width - 6).abs + "| Source Location" + " "*(source_filename_column_width - 15).abs + "| Benchmarked? |"
      end

      def method_columns(method)
        "| #{method.display_name}" + " "*(method_column_width - method.display_name.size) + "| #{method.display_filename}" + " "*(source_filename_column_width - method.display_filename.size) + "| #{method.excluded? ? "NO " : "YES"}          |"
      end

      def classes_count
        benchmarkable_methods.map(&:owner).uniq!.size
      end

      def file_count
        benchmarkable_methods.map(&:source_filename).uniq!.size
      end

      def print_table
        if RUBY_VERSION < "1.9"
          puts "Method benchmarking is not available in Ruby #{RUBY_VERSION}. It is only available in Ruby 1.9 or later."
        elsif CopperEgg::APM::Configuration.benchmark_methods_level == :disabled
          puts "Method benchmarking is disabled. You can enable method benchmarking by setting the benchmark_methods configuration value."
        elsif benchmarkable_methods.size == 0
          puts "No methods benchmarked"
        else
          puts
          puts "#{separator}\n#{header_columns}\n#{separator}\n#{benchmarkable_methods.map {|method| method_columns(method)}.join("\n")}\n#{separator}"
          puts "#{benchmarkable_methods.size} methods defined in #{classes_count} classes across #{file_count} files. #{benchmarkable_methods.size - excluded_methods.size == 1 ? "1 method" : "#{benchmarkable_methods.size - excluded_methods.size} methods"} benchmarked."
          puts
        end
      end

    end
  end
end