# -*- encoding : utf-8 -*-
require 'spec_helper'

class Foo
  def self.bar
    CopperEgg::APM.benchmark(self) { 100.times.reduce(:+) }
  end

  def bar
    CopperEgg::APM.benchmark(self) { 100.times.reduce(:+) }
  end

  def baz
    CopperEgg::APM.benchmark(nil) { 100.times.reduce(:+) }
  end
end

module Baz
  def self.bar
    CopperEgg::APM.benchmark(self) { 100.times.reduce(:+) }
  end
end

describe CopperEgg::APM do
  describe ".configure" do
    it "should send a payload with version and configuration settings" do
      Socket.any_instance.should_receive(:send) do |payload_cache, flag|
        hash = JSON.parse(payload_cache)
        expect(hash["version"]).to eq CopperEgg::APM::GEM_VERSION
        expect(hash["id"]).to match(/\A[0-1a-z]{16}\z/i)
        expect(hash["sql"]).to eq true
        expect(hash["http"]).to eq true
        expect(hash["exceptions"]).to eq true
        expect(hash["methods"]).to eq "disabled"
      end
      CopperEgg::APM.configure {|config|}
    end
  end

  describe ".trim_stacktrace" do
    it "should remove lines not in app root" do
      CopperEgg::APM::Configuration.app_root = "/deploy/current/"

      stacktrace = <<-LINES
      #{File.dirname(File.dirname(__FILE__))}/mysql2/client.rb:10:in `query'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/mysql2-0.2.18/lib/active_record/connection_adapters/mysql2_adapter.rb:265:in `block in execute'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/activerecord-3.0.20/lib/active_record/connection_adapters/abstract_adapter.rb:202:in `block in log'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/activesupport-3.0.20/lib/active_support/notifications/instrumenter.rb:21:in `instrument'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/activerecord-3.0.20/lib/active_record/connection_adapters/abstract_adapter.rb:200:in `log'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/mysql2-0.2.18/lib/active_record/connection_adapters/mysql2_adapter.rb:265:in `execute'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/mysql2-0.2.18/lib/active_record/connection_adapters/mysql2_adapter.rb:586:in `select'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/activerecord-3.0.20/lib/active_record/connection_adapters/abstract/database_statements.rb:7:in `select_all'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/activerecord-3.0.20/lib/active_record/connection_adapters/abstract/query_cache.rb:56:in `select_all'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/activerecord-3.0.20/lib/active_record/base.rb:473:in `find_by_sql'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/activerecord-3.0.20/lib/active_record/relation.rb:64:in `to_a'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/activerecord-3.0.20/lib/active_record/r>elation/finder_methods.rb:143:in `all'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job_active_record-0.3.3/lib/delayed/backend/active_record.rb:58:in `block in find_available'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/activesupport-3.0.20/lib/active_support/benchmarkable.rb:55:in `silence'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job_active_record-0.3.3/lib/delayed/backend/active_record.rb:57:in `find_available'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job-3.0.5/lib/delayed/backend/base.rb:45:in `reserve'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job-3.0.5/lib/delayed/worker.rb:258:in `reserve_and_run_one_job'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job-3.0.5/lib/delayed/worker.rb:187:in `block in work_off'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job-3.0.5/lib/delayed/worker.rb:186:in `times'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job-3.0.5/lib/delayed/worker.rb:186:in `work_off'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job-3.0.5/lib/delayed/worker.rb:151:in `block (4 levels) in start'
      /home/copperegg/.rvm/rubies/ruby-1.9.2-p290/lib/ruby/1.9.1/benchmark.rb:310:in `realtime'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job-3.0.5/lib/delayed/worker.rb:150:in `block (3 levels) in start'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job-3.0.5/lib/delayed/lifecycle.rb:60:in `call'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job-3.0.5/lib/delayed/lifecycle.rb:60:in `block in initialize'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job-3.0.5/lib/delayed/lifecycle.rb:65:in `call'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job-3.0.5/lib/delayed/lifecycle.rb:65:in `execute'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job-3.0.5/lib/delayed/lifecycle.rb:38:in `run_callbacks'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job-3.0.5/lib/delayed/worker.rb:149:in `block (2 levels) in start'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job-3.0.5/lib/delayed/worker.rb:148:in `loop'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job-3.0.5/lib/delayed/worker.rb:148:in `block in start'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job-3.0.5/lib/delayed/plugins/clear_locks.rb:7:in `call'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job-3.0.5/lib/delayed/plugins/clear_locks.rb:7:in `block (2 levels) in '
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job-3.0.5/lib/delayed/lifecycle.rb:78:in `call'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job-3.0.5/lib/delayed/lifecycle.rb:78:in `block (2 levels) in add'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job-3.0.5/lib/delayed/lifecycle.rb:60:in `call'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job-3.0.5/lib/delayed/lifecycle.rb:60:in `block in initialize'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job-3.0.5/lib/delayed/lifecycle.rb:78:in `call'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job-3.0.5/lib/delayed/lifecycle.rb:78:in `block in add'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job-3.0.5/lib/delayed/lifecycle.rb:65:in `call'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job-3.0.5/lib/delayed/lifecycle.rb:65:in `execute'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job-3.0.5/lib/delayed/lifecycle.rb:38:in `run_callbacks'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job-3.0.5/lib/delayed/worker.rb:147:in `start'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job-3.0.5/lib/delayed/command.rb:104:in `run'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job-3.0.5/lib/delayed/command.rb:92:in `block in run_process'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/daemons-1.1.9/lib/daemons/application.rb:255:in `call'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/daemons-1.1.9/lib/daemons/application.rb:255:in `block in start_proc'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/daemons-1.1.9/lib/daemons/daemonize.rb:82:in `call'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/daemons-1.1.9/lib/daemons/daemonize.rb:82:in `call_as_daemon'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/daemons-1.1.9/lib/daemons/application.rb:259:in `start_proc'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/daemons-1.1.9/lib/daemons/application.rb:296:in `start'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/daemons-1.1.9/lib/daemons/controller.rb:70:in `run'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/daemons-1.1.9/lib/daemons.rb:197:in `block in run_proc'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/daemons-1.1.9/lib/daemons/cmdline.rb:109:in `call'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/daemons-1.1.9/lib/daemons/cmdline.rb:109:in `catch_exceptions'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/daemons-1.1.9/lib/daemons.rb:196:in `run_proc'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job-3.0.5/lib/delay>ed/command.rb:90:in `run_process'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job-3.0.5/lib/delayed/command.rb:83:in `block in daemonize'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job-3.0.5/lib/delayed/command.rb:81:in `times'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/delayed_job-3.0.5/lib/delayed/command.rb:81:in `daemonize'
      script/delayed_job:5:in `'
      LINES
    
      expect(CopperEgg::APM.trim_stacktrace(stacktrace.split("\n"))).to eq [stacktrace.lines.to_a.last.strip]
    end

    it "should only include lines in app root" do
      CopperEgg::APM::Configuration.app_root = "/home/copperegg/rails/"

      stacktrace = <<-LINES
      #{File.dirname(File.dirname(__FILE__))}/lib/copperegg/apm/mysql2/client.rb:10:in `query'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/mysql2-0.2.18/lib/active_record/connection_adapters/mysql2_adapter.rb:265:in `block in execute'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/activerecord-3.0.20/lib/active_record/connection_adapters/abstract_adapter.rb:202:in `block in log'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/activesupport-3.0.20/lib/active_support/notifications/instrumenter.rb:21:in `instrument'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/activerecord-3.0.20/lib/active_record/connection_adapters/abstract_adapter.rb:200:in `log'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/mysql2-0.2.18/lib/active_record/connection_adapters/mysql2_adapter.rb:265:in `execute'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/mysql2-0.2.18/lib/active_record/connection_adapters/mysql2_adapter.rb:586:in `select'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/activerecord-3.0.20/lib/active_record/connection_adapters/abstract/database_statements.rb:7:in `select_all'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/activerecord-3.0.20/lib/active_record/connection_adapters/abstract/query_cache.rb:56:in `select_all'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/activerecord-3.0.20/lib/active_record/base.rb:473:in `find_by_sql'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/activerecord-3.0.20/lib/active_record/relation.rb:64:in `to_a'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/activerecord-3.0.20/lib/active_record/relation/finder_methods.rb:143:in `all'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/activerecord-3.0.20/lib/active_record/base.rb:444:in `all'
      /home/copperegg/rails/app/models/cluster.rb:60:in `populate_cache!'
      /home/copperegg/rails/app/models/cluster.rb:48:in `get_nodes'
      /home/copperegg/rails/lib/store.rb:48:in `io'
      /home/copperegg/rails/lib/store.rb:218:in `save'
      /home/copperegg/rails/app/models/sample.rb:74:in `stor'
      /home/copperegg/rails/app/models/sample.rb:284:in `block (2 levels) in save'
      /home/copperegg/rails/app/models/sample.rb:204:in `each'
      /home/copperegg/rails/app/models/sample.rb:204:in `block in save'
      /home/copperegg/rails/app/models/sample.rb:199:in `each'
      /home/copperegg/rails/app/models/sample.rb:199:in `save'
      /home/copperegg/rails/lib/worker.rb:401:in `save_sample'
      /home/copperegg/rails/lib/worker.rb:256:in `worker_run'
      /home/copperegg/rails/lib/worker.rb:170:in `block in start_worker'
      /home/copperegg/rails/lib/worker.rb:164:in `fork'
      /home/copperegg/rails/lib/worker.rb:164:in `start_worker'
      /home/copperegg/rails/lib/worker.rb:209:in `block (2 levels) in spawn_workers'
      /home/copperegg/rails/lib/worker.rb:206:in `times'
      /home/copperegg/rails/lib/worker.rb:206:in `block in spawn_workers'
      /home/copperegg/rails/lib/worker.rb:202:in `times'
      /home/copperegg/rails/lib/worker.rb:202:in `spawn_workers'
      /home/copperegg/rails/lib/worker.rb:153:in `run'
      /home/copperegg/rails/script/worker_daemon.rb:10:in `'
      LINES

      trimmed_lines = CopperEgg::APM.trim_stacktrace(stacktrace.split("\n")).map(&:strip)

      trimmed_stacktrace = <<-LINES
      /home/copperegg/rails/app/models/cluster.rb:60:in `populate_cache!'
      .../cluster.rb:48:in `get_nodes'
      /home/copperegg/rails/lib/store.rb:48:in `io'
      .../store.rb:218:in `save'
      /home/copperegg/rails/app/models/sample.rb:74:in `stor'
      .../sample.rb:284:in `block (2 levels) in save'
      .../sample.rb:204:in `each'
      .../sample.rb:204:in `block in save'
      .../sample.rb:199:in `each'
      .../sample.rb:199:in `save'
      /home/copperegg/rails/lib/worker.rb:401:in `save_sample'
      .../worker.rb:256:in `worker_run'
      .../worker.rb:170:in `block in start_worker'
      .../worker.rb:164:in `fork'
      .../worker.rb:164:in `start_worker'
      .../worker.rb:209:in `block (2 levels) in spawn_workers'
      .../worker.rb:206:in `times'
      .../worker.rb:206:in `block in spawn_workers'
      .../worker.rb:202:in `times'
      .../worker.rb:202:in `spawn_workers'
      .../worker.rb:153:in `run'
      /home/copperegg/rails/script/worker_daemon.rb:10:in `'
      LINES

      expect(trimmed_lines).to eq trimmed_stacktrace.split("\n").map(&:strip)
    end

    it "should include all lines if app root is not set" do
      CopperEgg::APM::Configuration.app_root = nil

      stacktrace = <<-LINES
      #{File.dirname(File.dirname(__FILE__))}/lib/copperegg/apm/mysql2/client.rb:10:in `query'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/mysql2-0.2.18/lib/active_record/connection_adapters/mysql2_adapter.rb:265:in `block in execute'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/activerecord-3.0.20/lib/active_record/connection_adapters/abstract_adapter.rb:202:in `block in log'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/activesupport-3.0.20/lib/active_support/notifications/instrumenter.rb:21:in `instrument'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/activerecord-3.0.20/lib/active_record/connection_adapters/abstract_adapter.rb:200:in `log'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/mysql2-0.2.18/lib/active_record/connection_adapters/mysql2_adapter.rb:265:in `execute'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/mysql2-0.2.18/lib/active_record/connection_adapters/mysql2_adapter.rb:586:in `select'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/activerecord-3.0.20/lib/active_record/connection_adapters/abstract/database_statements.rb:7:in `select_all'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/activerecord-3.0.20/lib/active_record/connection_adapters/abstract/query_cache.rb:56:in `select_all'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/activerecord-3.0.20/lib/active_record/base.rb:473:in `find_by_sql'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/activerecord-3.0.20/lib/active_record/relation.rb:64:in `to_a'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/activerecord-3.0.20/lib/active_record/relation/finder_methods.rb:143:in `all'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/activerecord-3.0.20/lib/active_record/base.rb:444:in `all'
      /home/copperegg/rails/app/models/cluster.rb:60:in `populate_cache!'
      /home/copperegg/rails/app/models/cluster.rb:48:in `get_nodes'
      /home/copperegg/rails/lib/store.rb:48:in `io'
      /home/copperegg/rails/lib/store.rb:218:in `save'
      /home/copperegg/rails/app/models/sample.rb:74:in `stor'
      /home/copperegg/rails/app/models/sample.rb:284:in `block (2 levels) in save'
      /home/copperegg/rails/app/models/sample.rb:204:in `each'
      /home/copperegg/rails/app/models/sample.rb:204:in `block in save'
      /home/copperegg/rails/app/models/sample.rb:199:in `each'
      /home/copperegg/rails/app/models/sample.rb:199:in `save'
      /home/copperegg/rails/lib/worker.rb:401:in `save_sample'
      /home/copperegg/rails/lib/worker.rb:256:in `worker_run'
      /home/copperegg/rails/lib/worker.rb:170:in `block in start_worker'
      /home/copperegg/rails/lib/worker.rb:164:in `fork'
      /home/copperegg/rails/lib/worker.rb:164:in `start_worker'
      /home/copperegg/rails/lib/worker.rb:209:in `block (2 levels) in spawn_workers'
      /home/copperegg/rails/lib/worker.rb:206:in `times'
      /home/copperegg/rails/lib/worker.rb:206:in `block in spawn_workers'
      /home/copperegg/rails/lib/worker.rb:202:in `times'
      /home/copperegg/rails/lib/worker.rb:202:in `spawn_workers'
      /home/copperegg/rails/lib/worker.rb:153:in `run'
      /home/copperegg/rails/script/worker_daemon.rb:10:in `'
      LINES

      trimmed_lines = CopperEgg::APM.trim_stacktrace(stacktrace.split("\n")).map(&:strip)

      trimmed_stacktrace = <<-LINES
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/mysql2-0.2.18/lib/active_record/connection_adapters/mysql2_adapter.rb:265:in `block in execute'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/activerecord-3.0.20/lib/active_record/connection_adapters/abstract_adapter.rb:202:in `block in log'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/activesupport-3.0.20/lib/active_support/notifications/instrumenter.rb:21:in `instrument'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/activerecord-3.0.20/lib/active_record/connection_adapters/abstract_adapter.rb:200:in `log'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/mysql2-0.2.18/lib/active_record/connection_adapters/mysql2_adapter.rb:265:in `execute'
      .../mysql2_adapter.rb:586:in `select'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/activerecord-3.0.20/lib/active_record/connection_adapters/abstract/database_statements.rb:7:in `select_all'
      .../query_cache.rb:56:in `select_all'
      .../base.rb:473:in `find_by_sql'
      .../relation.rb:64:in `to_a'
      /home/copperegg/.rvm/gems/ruby-1.9.2-p290@gems/activerecord-3.0.20/lib/active_record/relation/finder_methods.rb:143:in `all'
      .../base.rb:444:in `all'
      /home/copperegg/rails/app/models/cluster.rb:60:in `populate_cache!'
      .../cluster.rb:48:in `get_nodes'
      /home/copperegg/rails/lib/store.rb:48:in `io'
      .../store.rb:218:in `save'
      /home/copperegg/rails/app/models/sample.rb:74:in `stor'
      .../sample.rb:284:in `block (2 levels) in save'
      .../sample.rb:204:in `each'
      .../sample.rb:204:in `block in save'
      .../sample.rb:199:in `each'
      .../sample.rb:199:in `save'
      /home/copperegg/rails/lib/worker.rb:401:in `save_sample'
      .../worker.rb:256:in `worker_run'
      .../worker.rb:170:in `block in start_worker'
      .../worker.rb:164:in `fork'
      .../worker.rb:164:in `start_worker'
      .../worker.rb:209:in `block (2 levels) in spawn_workers'
      .../worker.rb:206:in `times'
      .../worker.rb:206:in `block in spawn_workers'
      .../worker.rb:202:in `times'
      .../worker.rb:202:in `spawn_workers'
      .../worker.rb:153:in `run'
      /home/copperegg/rails/script/worker_daemon.rb:10:in `'
      LINES

      expect(trimmed_lines).to eq trimmed_stacktrace.split("\n").map(&:strip)
    end
  end

  describe ".benchmark" do
    it "should measure class method execution time" do
      expect(Foo.bar).to eq 4950

      last_payload = CopperEgg::APM.send(:class_variable_get, :@@payload_cache).split("\x00").select {|i| i.size > 2}.map {|i| i.sub(/^[^\{]+/,'')}.last
      hash = JSON.parse last_payload
      
      expect(hash.keys.sort).to eq ["id", "inst"]
      expect(hash["id"]).to match(/\A[0-1a-z]{16}\z/i)
      expect(hash["inst"].keys.sort).to eq ["method", "time"]
      expect(hash["inst"]["method"]).to eq "Foo.bar {Ruby}"
      expect(hash["inst"]["time"].to_s).to match(/\A\d+\Z/)
    end

    it "should measure instance method execution time" do
      expect(Foo.new.bar).to eq 4950

      last_payload = CopperEgg::APM.send(:class_variable_get, :@@payload_cache).split("\x00").select {|i| i.size > 2}.map {|i| i.sub(/^[^\{]+/,'')}.last
      hash = JSON.parse last_payload
      
      expect(hash.keys.sort).to eq ["id", "inst"]
      expect(hash["id"]).to match(/\A[0-1a-z]{16}\z/i)
      expect(hash["inst"].keys.sort).to eq ["method", "time"]
      expect(hash["inst"]["method"]).to eq "Foo#bar {Ruby}"
      expect(hash["inst"]["time"].to_s).to match(/\A\d+\Z/)
    end

    it "should measure module method execution time" do
      expect(Baz.bar).to eq 4950

      last_payload = CopperEgg::APM.send(:class_variable_get, :@@payload_cache).split("\x00").select {|i| i.size > 2}.map {|i| i.sub(/^[^\{]+/,'')}.last
      hash = JSON.parse last_payload
      
      expect(hash.keys.sort).to eq ["id", "inst"]
      expect(hash["id"]).to match(/\A[0-1a-z]{16}\z/i)
      expect(hash["inst"].keys.sort).to eq ["method", "time"]
      expect(hash["inst"]["method"]).to eq "Baz.bar {Ruby}"
      expect(hash["inst"]["time"].to_s).to match(/\A\d+\Z/)
    end

    it "should not label the method based on the argument passed" do
      expect(Foo.new.baz).to eq 4950

      last_payload = CopperEgg::APM.send(:class_variable_get, :@@payload_cache).split("\x00").select {|i| i.size > 2}.map {|i| i.sub(/^[^\{]+/,'')}.last
      hash = JSON.parse last_payload
      
      expect(hash.keys.sort).to eq ["id", "inst"]
      expect(hash["id"]).to match(/\A[0-1a-z]{16}\z/i)
      expect(hash["inst"].keys.sort).to eq ["method", "time"]
      expect(hash["inst"]["method"]).to eq "NilClass#baz {Ruby}"
      expect(hash["inst"]["time"].to_s).to match(/\A\d+\Z/)
    end
  end

  describe ".obfuscate_sql" do
    it "shoudl obfuscate select statement" do
      sql = "SELECT `annotations`.* FROM `annotations` WHERE (`annotations`.id = 2) AND (updated_at > '#{Time.now.strftime('%Y-%m-%d %H:%M%S')}')"

      expect(CopperEgg::APM.obfuscate_sql(sql)).to eq "SELECT annotations.* FROM annotations WHERE (annotations.id = ?) AND (updated_at > ?)"
    end

    it "should obfuscate items in a list" do
      sql = 'SELECT COUNT(`items`.`id`) FROM `items` WHERE (`items`.id = 2) AND (state in ("enabled","expired"))'

      expect(CopperEgg::APM.obfuscate_sql(sql)).to eq "SELECT COUNT(items.id) FROM items WHERE (items.id = ?) AND (state in (?,?))"
    end

    it "should obfuscate update statement" do
      sql = "UPDATE `users` SET `phone` = '512.777.9311', `updated_at` = '#{Time.now.strftime('%Y-%m-%d %H:%M%S')}' WHERE `users`.`id` = 1"
      
      expect(CopperEgg::APM.obfuscate_sql(sql)).to eq "UPDATE users SET phone = ?, updated_at = ? WHERE users.id = ?"
    end

    it "should obfuscate delete statement" do
      sql = "DELETE FROM `reports` WHERE `reports`.`id` = 99"

      expect(CopperEgg::APM.obfuscate_sql(sql)).to eq "DELETE FROM reports WHERE reports.id = ?"
    end
  end
end