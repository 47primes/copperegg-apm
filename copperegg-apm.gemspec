require './lib/copperegg/apm/version'

Gem::Specification.new do |s|
  s.name    = 'copperegg-apm'
  s.version = CopperEgg::APM::GEM_VERSION
  s.authors = ['Mike Bradford']
  s.email   = 'mbradford@copperegg.com'
  s.date    = Time.now.utc.strftime("%Y-%m-%d")

  s.homepage    = 'http://github.com/copperegg/apm'
  s.summary     = "copperegg-apm-#{CopperEgg::APM::GEM_VERSION}"
  s.description = 'CopperEgg Application Performance Monitoring'
  s.license     = 'MIT'

  s.platform      = Gem::Platform::RUBY
  s.require_path  = 'lib'
  s.files         = Dir["#{File.dirname(__FILE__)}/**/*"] + %w(README.md Rakefile copperegg-apm.gemspec)
  s.test_files    = Dir.glob("spec/**/*.rb")
  s.rdoc_options  = ['--line-numbers', '--inline-source', '--title', 'copperegg-apm', '--main', 'README.md']
  s.executables   = ['copperegg-apm-init', 'copperegg-apm-methods']

  s.add_development_dependency 'rake', '~> 10.0.0'
  s.add_development_dependency 'rspec', '~> 2.11.0'
  s.add_development_dependency 'rspec-rails', '~> 2.0'
  s.add_development_dependency 'actionpack', '~> 3.0'
  s.add_development_dependency 'faker', '~> 1.1.2'
  s.add_development_dependency 'mysql', '~> 2.9'
  s.add_development_dependency 'mysql2', '~> 0.2'
  s.add_development_dependency 'sqlite3', '~> 1.3'
  s.add_development_dependency 'pg', '~> 0.9'
  s.add_development_dependency 'ethon', '~> 0.5'
  s.add_development_dependency 'typhoeus', '~> 0.3'
  s.add_development_dependency 'rest-client', '~> 1.6'
end
