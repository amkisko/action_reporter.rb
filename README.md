# action_reporter

[![Gem Version](https://badge.fury.io/rb/action_reporter.svg)](https://badge.fury.io/rb/action_reporter) [![Test Status](https://github.com/amkisko/action_reporter/actions/workflows/test.yml/badge.svg)](https://github.com/amkisko/action_reporter/actions/workflows/test.yml)

Ruby wrapper for multiple reporting services.

Supported services:
- Rails logger
- Audited
- Sentry
- Honeybadger
- scoutapm

Sponsored by [Kisko Labs](https://www.kiskolabs.com).

## Install

Using Bundler:
```sh
bundle add action_reporter
```

Using RubyGems:
```sh
gem install action_reporter
```

## Gemfile

```ruby
gem 'action_reporter'
```

## Usage

Put this in your `config/initializers/action_reporter.rb` file:

```ruby
ActionReporter.enabled_reporters = [
  ActionReporter::RailsReporter.new,
  # ActionReporter::AuditedReporter.new,
  # ActionReporter::SentryReporter.new,
  # ActionReporter::HoneybadgerReporter.new,
  # ActionReporter::ScoutApmReporter.new
]
```

Then you can use it in your code:

```ruby
ActionReporter.context(audited_user: current_user)
ActionReporter.notify('Something went wrong', context: { record: record })
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/amkisko/action_reporter

## Publishing

```sh
rm action_reporter-*.gem
gem build action_reporter.gemspec
gem push action_reporter-*.gem
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
