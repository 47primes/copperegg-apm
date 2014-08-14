require 'rake'
require File.join(File.dirname(__FILE__), 'benchmark_methods_table')

namespace :copperegg do
  namespace :apm  do
    desc "Prints a summary of all methods defined in your project and whether or not they are benchmarked."
    task :methods => :environment do
      CopperEgg::APM::BenchmarkMethodsTable.new.print_table
    end
  end
end
