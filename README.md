# CopperEgg APM

Monitor the performance of your application with code instrumentation and exception aggregation.

**Code instrumentation** measures the elapsed time used to execute a SQL statement, outbound HTTP request, or method call.

**Exception aggregation** monitors the number and type of exceptions occurring in your code.

## Getting Started

### Set Up Your CopperEgg Account

![CopperEgg App Screenshot](https://github.com/47primes/copperegg-apm/blob/master/screenshot01.png)

Login to your account at [CopperEgg.com](https://app.copperegg.com/login) and click on the `Apps` tag to create a new App. An App represents your existing application. Give it a descriptive name like 'MySaaSApp.com'.

You must add Code Instrumentation to your App. Each component of your application can be represented by an Instrument. Benchmarks from your app will be separated by Instrument. For example, you may want to create a separate Instrument for each daemon process in your application.

Copy your Instrument key. You will need to add it to your gem configuration as described below.

### Installation

You can install the `copperegg-apm` directly or use Bunder:

Install the gem directly

    gem install copperegg-apm

Using Bunder, add to your Gemfile

    gem 'copperegg-apm' 

#### Ruby on Rails 3+

Once the gem is bundled, you will need to generate a configuration file. Under your project's root directory, run:

    rails g copperegg:apm:init

This will create a configuration file at `config/initializers/copperegg_apm_config.rb`. You will be prompted to enter your Instrument key.

#### Sinatra and Other Ruby Environments

From your project's root directory, run `copperegg-apm-init`. This will create a configuration file named `copperegg_apm_config.rb`. You will be prompted to enter your Instrument key.

Require this file below your other require directives.

### Configuration

Instrumentation is initiated in your project by calling the `CopperEgg::APM.configure` block.

The auto-generated configuration script contains the default configuration values.

```ruby
CopperEgg::APM.configure do |config|
  config.instrument_key       = "your_instrument_key"
  config.benchmark_sql        = true                  # Benchmark database queries
  config.benchmark_exceptions = true
  config.benchmark_http       = true                  # Benchmark outgoing HTTP requests
  config.benchmark_methods(:disabled)
end
```

### Automatic Method Benchmarking

For performance reasons, automatic method benchmarking is disabled by default. When enabled, `CopperEgg::APM` intelligently adds benchmarking to public and protected methods defined within your codebase. By default, methods whose names begin with an underscore (_) or end with a question mark (?) are not benchmarked.

#### Configuring Automatic Method Benchmarking

Automatic method benchmarking is enabled by calling `config.benchmark_methods` within the configuration block. It expects a level which is represented by a symbol whose value is either `:disabled`, `:basic`, `:moderate`, `:full`, or `:custom`.

The levels `:basic` and `:moderate` are Rails-specific. With the `:basic` level only controller methods are automatically benchmarked. The `:moderate` level benchmarks all controller methods as well as methods of classes that descend from *ActiveRecord::Base*. Note that for controller actions, benchmarks also include rendering time.

A level `:full` benchmarks all methods within your project. For non-Rails projects, the `:basic` and `:moderate` levels will behave like the `:full` level.

The `:custom` level allows you to explicitly set which methods to benchmark. When setting `benchmark_methods` to :custom a second argument is expected which is an array of strings representing the methods to benchmark. The format of these strings is explained in the following section.

#### Inclusions and Exclusions

With automatic method benchmarking enabled, you can fine-tune the list of methods by passing either a hash (for values :basic, :moderate, or :full) or an array of strings (for :custom).

The hash must have keys named either :include or :exclude which are set to an array of strings.

Each string in these arrays must follow the pattern *method_name*, *Class*, *ClassNameSpace::*, *Class.class_method*, *Class#instance_method*.

The following is an example configuration that only benchmarks a discreet set of methods:

```ruby
config.benchmark_methods :custom, %w(User.authenticate! run MyApp::)
```

In the example above, the only methods benchmarked will be the method 'authenticate!' in class 'User', any method named 'run' in any instance or class defined in your project, and any method defined in a class having a namespace 'MyApp::'. So any method defined in a class named MyApp::MiddleWare or Api::MyApp::StatisticsController would be benchmarked.

By contrast, you can benchmark all methods defined in your project except for a discreet set:

```ruby
config.benchmark_methods :full, :exclude => %w(User#full_name User#last_name Widget.expired MyLogger perform)
```

In the example above, the methods 'full_name' and 'last_name' in any instance of class 'User', the class method 'expired' in class 'Widget', any instance or class method in 'MyLogger' and any method named 'perform' in any instance or class will not be benchmarked.

Similarly, any method in your project not benchmarked by default can be included:

```ruby
config.benchmark_methods :basic, :include => %w(BackgroundJob#running? User#_callback_after_1135 User#_callback_after_1136)
```

These options can be used in conjunction:

```ruby
config.benchmark_methods :moderate, :include => %w(MyCustomLibrary), :exclude => %w(ReportsController User#generate_password)
```

In the case where a method is named in both *include* and *exclude* lists, the *exclude* list takes precendence.

For a Rails project, run `rake copperegg:apm:methods` on the command line in your application root directory to print a list of all methods defined in your project and whether or not they are benchmarked.

For non-Rails projects, this can be acheived by running `copperegg-apm-methods` on the command line in your application root directory.

Automatic method benchmarking is only available for Ruby 1.9+ and REE.

**Because benchmarking is added to your methods using reflection and metaprogramming, you should use this directive with discretion to avoid performance degredation.**

#### Block-based Method Benchmarking

Even with method benchmarking disabled, you can still benchmark blocks of code with the `CopperEgg::APM.benchmark` method.

```ruby
def generate_password(length=16)
  CopperEgg::APM.benchmark(self) do
    chars = ("a".."z").to_a + ("0".."9").to_a + %w($ * - _)          
    password = Array.new(length).map { chars[rand(chars.length)].send([:upcase,:downcase][rand(2)]) }.join
    while !PASSWORD_PATTERN.match(password) do
      password = generate_password(length, include_special)
    end
  end
  password
end
```

### Supported Databases

Database query benchmarking is supported for the following engines:

+ MySQL (via the mysql and mysql2 gems)
+ PostgreSQL (via the pg gem)
+ SQLite (via the sqlite3 gem)

### Supported Gems For Benchmarking Outbound HTTP Requests

Outbound HTTP requests performed within your project will be benchmarked from any of the following sources:

+ Net/HTTP
+ Ethon
+ Typhoeus::Hydra
+ RestClient

## Exception Aggregation

When exception benchmarking is enabled, any exception raised in your project will be aggregated by class, source location, and system.

## Disable Gem Functionality

To disable all functionality of this gem, call `config.disable` in the configuration block and then restart your application:

```ruby
CopperEgg::APM.configure do |config|
  config.disable
end
```

## License

CopperEgg::APM is released under the [MIT license](http://www.opensource.org/licenses/MIT).