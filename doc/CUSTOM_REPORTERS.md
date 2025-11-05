# Custom Reporters Guide

ActionReporter supports custom reporters, allowing you to integrate with any reporting service (e.g., Datadog, New Relic, custom logging systems).

## Quick Example: Datadog Reporter

### Step 1: Create the Reporter Class

Create `lib/reporters/datadog_reporter.rb` in your application:

```ruby
module ActionReporter
  class DatadogReporter < Base
    def initialize(api_key: nil, service: "myapp")
      @api_key = api_key
      @service = service
      # Initialize Datadog client here
      # @datadog_client = Datadog::Client.new(api_key: api_key)
    end

    def notify(error, context: {})
      new_context = transform_context(context)
      
      # Send error to Datadog
      # @datadog_client.send_event(
      #   title: "Error: #{error}",
      #   text: error.message,
      #   alert_type: "error",
      #   tags: ["service:#{@service}"],
      #   context: new_context
      # )
    end

    def context(args)
      new_context = transform_context(args)
      # Set Datadog context
      # @datadog_client.set_context(new_context)
    end

    def reset_context
      # Reset Datadog context
      # @datadog_client.reset_context
    end
  end
end
```

### Step 2: Register the Reporter

In `config/initializers/action_reporter.rb`:

```ruby
# Register the custom reporter (optional - only needed if you want it in available_reporters)
ActionReporter.register_reporter(:datadog,
  class_name: "ActionReporter::DatadogReporter",
  require_path: "reporters/datadog_reporter"
)

# Configure enabled reporters
ActionReporter.enabled_reporters = [
  (ActionReporter::RailsReporter.new if Rails.env.development?),
  ActionReporter::DatadogReporter.new(
    api_key: ENV["DATADOG_API_KEY"],
    service: "myapp"
  )
].compact
```

### Step 3: Use It

```ruby
# Set context
ActionReporter.current_user = current_user
ActionReporter.context(entry_id: entry.id)

# Report errors
ActionReporter.notify(error, context: { record: record })
```

## Alternative: Skip Registration (Direct Usage)

If you don't need the reporter to appear in `available_reporters`, you can skip registration:

```ruby
# In config/initializers/action_reporter.rb
ActionReporter.enabled_reporters = [
  ActionReporter::DatadogReporter.new(api_key: ENV["DATADOG_API_KEY"])
]
```

## Reporter Interface

All custom reporters must inherit from `ActionReporter::Base` and can implement:

- `notify(error, context: {})` - Report an error or message
- `context(args)` - Set contextual information
- `reset_context` - Reset context (called on request cleanup)
- `current_user=(user)` - Set current user (optional)
- `current_request_uuid=(uuid)` - Set request UUID (optional)
- `current_remote_addr=(addr)` - Set remote address (optional)
- `check_in(identifier)` - Heartbeat/check-in (optional)

All methods are optional and have default no-op implementations in `Base`.

## Available Methods from Base

- `transform_context(context)` - Transforms context, converting GlobalID objects to strings
- `resolve_check_in_id(identifier)` - Resolves check-in identifier

## Examples

### Simple Logger Reporter

```ruby
module ActionReporter
  class FileLoggerReporter < Base
    def initialize(log_file: "log/action_reporter.log")
      @log_file = log_file
    end

    def notify(error, context: {})
      File.open(@log_file, "a") do |f|
        f.puts "[#{Time.now}] ERROR: #{error.inspect}"
        f.puts "Context: #{transform_context(context).inspect}"
      end
    end
  end
end
```

### New Relic Reporter

```ruby
module ActionReporter
  class NewRelicReporter < Base
    def notify(error, context: {})
      if error.is_a?(StandardError)
        NewRelic::Agent.notice_error(error, custom_params: transform_context(context))
      else
        NewRelic::Agent.record_custom_event("CustomError", {
          message: error.to_s,
          context: transform_context(context)
        })
      end
    end

    def context(args)
      NewRelic::Agent.add_custom_attributes(transform_context(args))
    end
  end
end
```

### Slack Reporter

```ruby
module ActionReporter
  class SlackReporter < Base
    def initialize(webhook_url:)
      @webhook_url = webhook_url
    end

    def notify(error, context: {})
      payload = {
        text: "Error: #{error}",
        attachments: [{
          fields: transform_context(context).map { |k, v| { title: k, value: v.to_s, short: true } }
        }]
      }
      
      # HTTP.post(@webhook_url, json: payload)
    end
  end
end
```

## Best Practices

1. **Inherit from Base**: Always inherit from `ActionReporter::Base` to get helper methods
2. **Use transform_context**: Always use `transform_context` to handle GlobalID objects and nested structures
3. **Handle Errors Gracefully**: Don't let reporter failures break your application
4. **Thread Safety**: ActionReporter handles thread safety, but ensure your reporter's backend client is thread-safe
5. **Lazy Loading**: Register reporters in initializers, but actual work happens when `notify` is called

## Registration Benefits

Registering a reporter (vs. just using it directly) provides:

- Appears in `ActionReporter.available_reporters`
- Can be discovered by other tools/frameworks
- Better integration with plugin systems
- Consistent API across all reporters

## Testing Custom Reporters

```ruby
# spec/support/action_reporter.rb
RSpec.configure do |config|
  config.before(:each) do
    ActionReporter::PluginDiscovery.reset!
    ActionReporter::PluginDiscovery.instance_variable_set(:@registered_reporters, {})
  end
end

# spec/reporters/datadog_reporter_spec.rb
RSpec.describe ActionReporter::DatadogReporter do
  let(:reporter) { described_class.new(api_key: "test-key") }

  it "reports errors" do
    expect { reporter.notify("Error", context: {foo: "bar"}) }.not_to raise_error
  end
end
```

