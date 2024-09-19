# action_reporter

[![Gem Version](https://badge.fury.io/rb/action_reporter.svg)](https://badge.fury.io/rb/action_reporter) [![Test Status](https://github.com/amkisko/action_reporter.rb/actions/workflows/test.yml/badge.svg)](https://github.com/amkisko/action_reporter.rb/actions/workflows/test.yml) [![codecov](https://codecov.io/gh/amkisko/action_reporter.rb/graph/badge.svg?token=JCV2A7NWTE)](https://codecov.io/gh/amkisko/action_reporter.rb)

[![Codacy Badge](https://app.codacy.com/project/badge/Grade/f4bef9a52eac43a5a0f6d8c1b58cc6af)](https://app.codacy.com/gh/amkisko/action_reporter.rb/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade) [![Codacy Badge](https://app.codacy.com/project/badge/Coverage/f4bef9a52eac43a5a0f6d8c1b58cc6af)](https://app.codacy.com/gh/amkisko/action_reporter.rb/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_coverage)

Ruby wrapper for multiple reporting services.

Supported services:
- Rails logger
- Audited
- PaperTrail
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
  # ActionReporter::PaperTrailReporter.new,
  # ActionReporter::SentryReporter.new,
  # ActionReporter::HoneybadgerReporter.new,
  # ActionReporter::ScoutApmReporter.new
]
```

Then you can use it in your code:

```ruby
ActionReporter.audited_user = current_user
ActionReporter.context(entry_id: entry.id)
ActionReporter.notify('Something went wrong', context: { record: record })
```

## Hook debugger to notify method

Apply patch on initializer level or before running the main code:

```ruby
module ActionReporter
  class RailsReporter < Base
    def notify(error, context: {})
      super
      binding.pry
    end
  end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/amkisko/action_reporter.rb

Contribution policy:
- It might take up to 2 calendar weeks to review and merge critical fixes
- It might take up to 6 calendar months to review and merge pull request
- It might take up to 1 calendar year to review an issue
- New integrations and third-party features are not nessessarily added to the gem
- Pull request should have test coverage for affected parts
- Pull request should have changelog entry

## Publishing

```sh
rm action_reporter-*.gem
gem build action_reporter.gemspec
gem push action_reporter-*.gem
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
