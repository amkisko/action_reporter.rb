require "spec_helper"

# Example: Custom Datadog Reporter
# This demonstrates how users can add custom reporters
module ActionReporter
  class DatadogReporter < Base
    def initialize(api_key: nil, service: "myapp")
      @api_key = api_key
      @service = service
    end

    def notify(error, context: {})
      # Simulate Datadog API call
      transform_context(context)
      # In real implementation, this would send to Datadog
      # datadog_client.send_event(error, new_context)
    end

    def context(args)
      transform_context(args)
      # In real implementation, this would set Datadog context
      # datadog_client.set_context(new_context)
    end

    def reset_context
      # In real implementation, this would reset Datadog context
      # datadog_client.reset_context
    end
  end
end

RSpec.describe "Custom Reporter Example (Datadog)" do
  before do
    ActionReporter::PluginDiscovery.reset!
    ActionReporter::PluginDiscovery.instance_variable_set(:@registered_reporters, {})
  end

  describe "registering a custom Datadog reporter" do
    it "allows users to register custom reporters" do
      # Step 1: Create the reporter class (e.g., in lib/reporters/datadog_reporter.rb)
      # The class is already defined in this spec file for demonstration

      # Step 2: Register it in an initializer
      # Note: require_path is optional if class is already loaded
      ActionReporter.register_reporter(:datadog,
        class_name: "ActionReporter::DatadogReporter",
        require_path: "reporters/datadog_reporter") # This would be the actual path in user's app

      # Step 3: The reporter is now available
      available = ActionReporter.available_reporters
      expect(available).to include(ActionReporter::DatadogReporter)
    end

    it "allows using the custom reporter" do
      # Register the reporter (require_path optional if class already loaded)
      ActionReporter.register_reporter(:datadog,
        class_name: "ActionReporter::DatadogReporter",
        require_path: "reporters/datadog_reporter")

      # Create and use the reporter
      datadog_reporter = ActionReporter::DatadogReporter.new(api_key: "test-key", service: "myapp")
      ActionReporter.enabled_reporters = [datadog_reporter]

      # Use it
      expect { ActionReporter.notify("Test error", context: {foo: "bar"}) }.not_to raise_error
    end

    it "includes custom reporters in available_reporters" do
      ActionReporter.register_reporter(:datadog,
        class_name: "ActionReporter::DatadogReporter",
        require_path: "reporters/datadog_reporter")

      available = ActionReporter.available_reporters

      # Should include both built-in and custom reporters
      expect(available).to include(ActionReporter::RailsReporter) # Built-in
      expect(available).to include(ActionReporter::DatadogReporter) # Custom
    end

    it "works with multiple custom reporters" do
      # Register multiple custom reporters
      ActionReporter.register_reporter(:datadog,
        class_name: "ActionReporter::DatadogReporter",
        require_path: "reporters/datadog_reporter")

      # Create another custom reporter class
      custom_reporter_class = Class.new(ActionReporter::Base) do
        def self.name
          "ActionReporter::CustomReporter"
        end
      end
      stub_const("ActionReporter::CustomReporter", custom_reporter_class)

      ActionReporter.register_reporter(:custom,
        class_name: "ActionReporter::CustomReporter",
        require_path: "action_reporter/rails_reporter") # Using existing path for test

      available = ActionReporter.available_reporters
      expect(available).to include(ActionReporter::DatadogReporter)
      expect(available).to include(custom_reporter_class)
    end
  end

  describe "real-world usage example" do
    it "demonstrates complete setup in a Rails initializer" do
      # This is how it would look in config/initializers/action_reporter.rb:

      # 1. Register custom reporter (if needed)
      # ActionReporter.register_reporter(:datadog,
      #   class_name: "MyApp::DatadogReporter",
      #   require_path: "my_app/datadog_reporter"
      # )

      # 2. Configure enabled reporters
      datadog_reporter = ActionReporter::DatadogReporter.new(api_key: ENV["DATADOG_API_KEY"])
      ActionReporter.enabled_reporters = [
        ActionReporter::RailsReporter.new,
        datadog_reporter
      ]

      # 3. Use it
      expect { ActionReporter.notify("Error", context: {}) }.not_to raise_error
    end
  end
end
