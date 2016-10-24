module CopperEgg
  module APM
    # CopperEgg::APM::UnboundMethod
    module UnboundMethod
      def class_method?
        class_method == true
      end

      def benchmarkable?
        return false if !user_defined? || attribute?
        name =~ /\A[\w\d\!\?]+\z/ ? true : false
      end

      def user_defined?
        return false if source_filename.nil? || !File.exist?(source_filename)
        paths = Gem.path + [Gem.dir, CopperEgg::APM::Configuration.gem_root, "/lib/ruby/",
                            "/site_ruby/", "/vendor_ruby/", "/gems/"]
        source_filename ? paths.select! { |path| source_filename.include?(path) }.empty? : false
      end

      def attribute?
        parent_class.instance_methods.include?("#{name}=".to_sym)
      end

      def name_begins_with_underscore_or_ends_with_question_mark?
        name.start_with?("_") || name =~ /\A[\w\d]+\?\z/
      end

      def source_filename
        @source_filename ||= if respond_to?(:source_location)
                               source_location.to_a.first
                             elsif respond_to?(:__file__)
                               __file__
                             end
      end

      def source_line
        @source_line ||= if respond_to?(:source_location)
                           source_location.to_a.last
                         elsif respond_to?(:__line__)
                           __line__
                         end
      end

      def display_filename
        return @display_filename if @display_filename
        @display_filename = "#{source_filename}:#{source_line}"
        @display_filename.sub!(::Rails.configuration.root.to_s, "...") if defined?(::Rails)
        @display_filename
      end

      def display_name
        "#{parent_class}#{class_method? ? '.' : '#'}#{name}"
      end

      def class_eval_string
        <<-DEF
          #{'class << self' if class_method?}
          alias_method "_cu_#{name}", "#{name}"
          def #{name}(*args)
            starttime = (Time.now.to_f * 1000.0).to_i
            result = block_given? ? _cu_#{name}(*args,&Proc.new) : _cu_#{name}(*args)
            time = (Time.now.to_f * 1000.0).to_i - starttime

            CopperEgg::APM.send_payload(method: "#{display_name}", time: time)

            result
          end
          #{'end' if class_method?}
        DEF
      end

      def add_benchmarking
        parent_class.module_eval(class_eval_string)
      end

      def benchmark_levels
        levels = [:full, :custom]
        return levels unless defined?(::Rails)

        levels.push(:moderate) if parent_class < ::ActiveRecord::Base
        levels.push(:basic) if parent_class < ::ActionController::Base
        levels
      end

      def excluded?
        return true if CopperEgg::APM::Configuration.benchmark_methods_level == :disabled

        return false if CopperEgg::APM::Configuration.only_methods.include?(parent_class.to_s)
        return false if CopperEgg::APM::Configuration.only_methods.include?(display_name)
        return false if CopperEgg::APM::Configuration.only_methods.include?(name)
        CopperEgg::APM::Configuration.only_methods.each do |value|
          return false if value =~ /::\Z/ && parent_class.to_s.include?(value)
        end

        if CopperEgg::APM::Configuration.only_methods.any?
          if !CopperEgg::APM::Configuration.only_methods.include?(parent_class.to_s) &&
             !CopperEgg::APM::Configuration.only_methods.include?(display_name) &&
             !CopperEgg::APM::Configuration.only_methods.include?(name)
            return true
          end
        end

        return true if CopperEgg::APM::Configuration.exclude_methods.include?(parent_class.to_s)
        return true if CopperEgg::APM::Configuration.exclude_methods.include?(display_name)
        return true if CopperEgg::APM::Configuration.exclude_methods.include?(display_name)
        CopperEgg::APM::Configuration.exclude_methods.each do |value|
          return true if value =~ /::\Z/ && parent_class.to_s.include?(value)
        end

        if CopperEgg::APM::Configuration.include_methods.include?(parent_class.to_s) &&
           !name_begins_with_underscore_or_ends_with_question_mark?
          return false
        end
        return false if CopperEgg::APM::Configuration.include_methods.include?(display_name)
        return false if CopperEgg::APM::Configuration.include_methods.include?(name)
        CopperEgg::APM::Configuration.include_methods.each do |value|
          if value =~ /::\Z/ && parent_class.to_s.include?(value) &&
             !name_begins_with_underscore_or_ends_with_question_mark?
            return false
          end
        end

        return true if name_begins_with_underscore_or_ends_with_question_mark?

        if benchmark_levels.include?(CopperEgg::APM::Configuration.benchmark_methods_level)
          return false
        end

        true
      end
    end
  end
end

# UnboundMethod
class UnboundMethod
  include CopperEgg::APM::UnboundMethod
  attr_accessor :parent_class, :class_method
end
