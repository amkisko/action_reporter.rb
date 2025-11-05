# action_reporter

[![Gem Version](https://badge.fury.io/rb/action_reporter.svg)](https://badge.fury.io/rb/action_reporter) [![Test Status](https://github.com/amkisko/action_reporter.rb/actions/workflows/test.yml/badge.svg)](https://github.com/amkisko/action_reporter.rb/actions/workflows/test.yml) [![codecov](https://codecov.io/gh/amkisko/action_reporter.rb/graph/badge.svg?token=JCV2A7NWTE)](https://codecov.io/gh/amkisko/action_reporter.rb)

Ruby wrapper for multiple reporting services.

Supported services: Rails logger, gem audited, gem PaperTrail, Sentry, Honeybadger, scoutapm.

Sponsored by [Kisko Labs](https://www.kiskolabs.com).

<a href="https://www.kiskolabs.com">
  <img src="kisko.svg" width="200" alt="Sponsored by Kisko Labs" />
</a>


## Installation

Add to your Gemfile:

```ruby
gem "action_reporter"
```

Run `bundle install` or `gem install action_reporter`.


## Usage

Create `config/initializers/action_reporter.rb`:

```ruby
ActionReporter.enabled_reporters = [
  (ActionReporter::RailsReporter.new if Rails.env.development?),
  # ActionReporter::AuditedReporter.new,
  # ActionReporter::PaperTrailReporter.new,
  # ActionReporter::SentryReporter.new,
  # ActionReporter::HoneybadgerReporter.new,
  # ActionReporter::ScoutApmReporter.new
].compact
```

Set context and report errors:

```ruby
ActionReporter.current_user = current_user
ActionReporter.current_request_uuid = request.env["action_dispatch.request_id"]
ActionReporter.current_remote_addr = request.remote_ip

ActionReporter.context(entry_id: entry.id)
ActionReporter.notify("Something went wrong", context: { record: record })
ActionReporter.reset_context
```

## Transaction support

ActionReporter supports transaction tracking with automatic context preservation:

```ruby
# Attribute-style setters
ActionReporter.transaction_id = "txn-123"
ActionReporter.transaction_name = "GET /api/users"

# Block-based (preserves previous values)
ActionReporter.transaction(name: "GET /api/users", id: "txn-123") do
  # Your code here
end
```

## Custom Reporters

Create custom reporters by inheriting from `ActionReporter::Base`:

```ruby
module ActionReporter
  class CustomReporter < Base
    def notify(error, context: {})
      new_context = transform_context(context)
      # Send to your service
    end

    def context(args)
      new_context = transform_context(args)
      # Set context in your service
    end
  end
end

ActionReporter.enabled_reporters = [ActionReporter::CustomReporter.new]
```

See `doc/CUSTOM_REPORTERS.md` for detailed documentation.

## Advanced Integration

ActionReporter can be extended with custom methods and integrated with `ActiveSupport::CurrentAttributes` for automatic context propagation:

```ruby
module ActionReporter
  def self.set_transaction_id(transaction_id)
    context(transaction_id: transaction_id)
    Sentry.set_tags(transactionId: transaction_id) if defined?(Sentry)
  end
end

class Current < ActiveSupport::CurrentAttributes
  attribute :user, :reporter_transaction_id

  def user=(user)
    super
    ActionReporter.current_user = user
  end

  def reporter_transaction_id=(transaction_id)
    super
    ActionReporter.transaction_id = transaction_id
  end
end
```

## API

- `ActionReporter.enabled_reporters = [...]` - Configure enabled reporters
- `ActionReporter.current_user = user` - Set current user (thread-safe)
- `ActionReporter.current_request_uuid = uuid` - Set request UUID
- `ActionReporter.current_remote_addr = addr` - Set remote address
- `ActionReporter.context(**args)` - Set context for all reporters
- `ActionReporter.notify(error, context: {})` - Report errors/messages
- `ActionReporter.reset_context` - Reset all context
- `ActionReporter.transaction_id = id` - Set transaction ID
- `ActionReporter.transaction_name = name` - Set transaction name
- `ActionReporter.transaction(name:, id:, **context, &block)` - Block-based transaction with context preservation
- `ActionReporter.check_in(identifier)` - Heartbeat/check-in
- `ActionReporter.logger = logger` - Configure error logger
- `ActionReporter.error_handler = proc` - Configure error handler callback


## Development

```bash
bundle install
bundle exec appraisal install
bundle exec rspec
bin/appraisals
bundle exec standardrb --fix
```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/amkisko/action_reporter.rb

Contribution policy:
- New features are not necessarily added to the gem
- Pull request should have test coverage for affected parts
- Pull request should have changelog entry

Review policy:
- It might take up to 2 calendar weeks to review and merge critical fixes
- It might take up to 6 calendar months to review and merge pull request
- It might take up to 1 calendar year to review an issue


## Publishing

```sh
rm action_reporter-*.gem
gem build action_reporter.gemspec
gem push action_reporter-*.gem
```


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
