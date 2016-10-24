require "rubygems"
require "rubygems/command.rb"
require "rubygems/dependency_installer.rb"

begin
  Gem::Command.build_args = ARGV
rescue NoMethodError
end

inst = Gem::DependencyInstaller.new

begin
  inst.install "json " if RUBY_VERSION < "1.9"
rescue
  exit(1)
end

# create dummy rakefile to indicate success
f = File.open(File.join(File.dirname(__FILE__), "Rakefile"), "w")
f.write("task :default\n")
f.close
