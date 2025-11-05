require "spec_helper"

RSpec.describe ActionReporter::PluginDiscovery do
  describe ".discover" do
    before do
      described_class.reset!
    end

    it "discovers built-in reporters" do
      reporters = described_class.discover

      expect(reporters).to include(ActionReporter::RailsReporter)
      expect(reporters).to include(ActionReporter::SentryReporter)
      expect(reporters).to include(ActionReporter::HoneybadgerReporter)
      expect(reporters).to include(ActionReporter::ScoutApmReporter)
      expect(reporters).to include(ActionReporter::AuditedReporter)
      expect(reporters).to include(ActionReporter::PaperTrailReporter)
    end

    it "only includes classes that inherit from Base" do
      reporters = described_class.discover

      reporters.each do |reporter|
        expect(reporter).to be < ActionReporter::Base
      end
    end

    it "caches results" do
      first_call = described_class.discover
      second_call = described_class.discover

      expect(first_call).to be(second_call) # Same object (frozen)
    end

    it "is thread-safe" do
      threads = []
      results = []

      10.times do
        threads << Thread.new do
          results << described_class.discover
        end
      end

      threads.each(&:join)

      # All threads should get the same result
      expect(results.uniq.size).to eq(1)
    end

    it "handles files that don't define valid reporter classes" do
      # Test that files without matching classes are skipped
      # This is tested implicitly by only valid reporters being discovered
      reporters = described_class.discover

      # All discovered reporters should be valid
      reporters.each do |reporter|
        expect(reporter).to be < ActionReporter::Base
      end
    end

    it "handles discovery errors gracefully" do
      logger = double("Logger")
      ActionReporter.logger = logger

      # Mock discover_reporter_from_file to raise an error
      allow(described_class).to receive(:discover_reporter_from_file).and_raise(StandardError.new("Discovery error"))

      # Discovery should not raise, but should warn (Kernel.warn is used, not logger.warn)
      expect {
        described_class.reset!
        described_class.discover
      }.not_to raise_error

      ActionReporter.logger = nil
    end
  end

  describe ".register" do
    before do
      # Clear any existing registrations
      described_class.instance_variable_set(:@registered_reporters, {})
    end

    it "registers a custom reporter" do
      described_class.register(:custom, class_name: "ActionReporter::RailsReporter", require_path: "action_reporter/rails_reporter")

      registered = described_class.instance_variable_get(:@registered_reporters)
      expect(registered[:custom]).to eq({
        class_name: "ActionReporter::RailsReporter",
        require_path: "action_reporter/rails_reporter"
      })
    end
  end

  describe ".available_reporters" do
    before do
      described_class.reset!
      described_class.instance_variable_set(:@registered_reporters, {})
    end

    it "includes discovered reporters" do
      reporters = described_class.available_reporters

      expect(reporters).to include(ActionReporter::RailsReporter)
      expect(reporters).to include(ActionReporter::SentryReporter)
    end

    it "includes registered reporters" do
      # Create a mock reporter class for testing
      custom_reporter_class = Class.new(ActionReporter::Base) do
        def self.name
          "ActionReporter::CustomTestReporter"
        end
      end

      stub_const("ActionReporter::CustomTestReporter", custom_reporter_class)

      # Register using an already-loaded reporter path to avoid LoadError
      described_class.register(:custom_test, class_name: "ActionReporter::CustomTestReporter", require_path: "action_reporter/rails_reporter")

      reporters = described_class.available_reporters

      expect(reporters).to include(custom_reporter_class)
    end

    it "does not include duplicate reporters" do
      # Register a reporter that's already discovered
      described_class.register(:rails, class_name: "ActionReporter::RailsReporter", require_path: "action_reporter/rails_reporter")

      reporters = described_class.available_reporters

      rails_count = reporters.count { |r| r == ActionReporter::RailsReporter }
      expect(rails_count).to eq(1)
    end

    it "handles registered reporters that don't exist" do
      # Register a reporter with a non-existent class
      described_class.register(:nonexistent, class_name: "ActionReporter::NonExistentReporter", require_path: "action_reporter/nonexistent_reporter")

      reporters = described_class.available_reporters

      # Should not include non-existent reporter (should still include discovered reporters)
      expect(reporters).not_to be_empty
      expect(reporters.find { |r| r.name == "ActionReporter::NonExistentReporter" }).to be_nil
    end

    it "handles registered reporters that don't inherit from Base" do
      # Create a class that doesn't inherit from Base
      non_base_class = Class.new do
        def self.name
          "ActionReporter::NonBaseReporter"
        end
      end
      stub_const("ActionReporter::NonBaseReporter", non_base_class)

      described_class.register(:non_base, class_name: "ActionReporter::NonBaseReporter", require_path: "action_reporter/rails_reporter")

      reporters = described_class.available_reporters

      # Should not include non-Base reporter
      expect(reporters).not_to include(non_base_class)
    end

    it "handles LoadError when requiring registered reporter" do
      logger = double("Logger")
      ActionReporter.logger = logger

      # Create a reporter class but with a non-existent require path
      custom_reporter_class = Class.new(ActionReporter::Base) do
        def self.name
          "ActionReporter::LoadErrorTestReporter"
        end
      end
      stub_const("ActionReporter::LoadErrorTestReporter", custom_reporter_class)

      described_class.register(:load_error_test,
        class_name: "ActionReporter::LoadErrorTestReporter",
        require_path: "nonexistent/path/that/will/fail")

      # Mock the require call to raise LoadError
      allow(Kernel).to receive(:require).with("nonexistent/path/that/will/fail").and_raise(LoadError.new("cannot load such file"))

      # Should not raise, but should warn (Kernel.warn is used when logger exists)
      expect { described_class.available_reporters }.not_to raise_error

      ActionReporter.logger = nil
    end

    it "handles registered reporter errors gracefully" do
      logger = double("Logger")
      ActionReporter.logger = logger

      # Register a reporter that will cause an error when loading
      described_class.register(:error_test,
        class_name: "ActionReporter::ErrorTestReporter",
        require_path: "action_reporter/rails_reporter")

      # Mock Object.const_defined? to raise an error only for this specific class
      original_const_defined = Object.method(:const_defined?)
      allow(Object).to receive(:const_defined?) do |name, *args|
        if name == "ActionReporter::ErrorTestReporter"
          raise StandardError.new("Test error")
        else
          original_const_defined.call(name, *args)
        end
      end

      # Should not raise, but should warn (Kernel.warn is used when logger exists)
      expect { described_class.available_reporters }.not_to raise_error

      ActionReporter.logger = nil
    end
  end

  describe ".reset!" do
    it "clears the discovery cache" do
      first_discovery = described_class.discover
      described_class.reset!
      second_discovery = described_class.discover

      expect(first_discovery).not_to be(second_discovery)
      expect(first_discovery).to eq(second_discovery) # Same content, different objects
    end
  end

  describe "private methods" do
    describe ".discover_reporter_from_file" do
      it "returns nil for files without matching classes" do
        # Test with a file that would have a class name that doesn't exist
        # The method converts "test_reporter" -> "TestReporter" -> "ActionReporter::TestReporter"
        # But that class doesn't exist, so it should return nil
        result = described_class.send(:discover_reporter_from_file, "/test/test_reporter.rb")
        expect(result).to be_nil
      end

      it "returns nil for classes that don't inherit from Base" do
        # Create a class that exists but doesn't inherit from Base
        non_base_class = Class.new do
          def self.name
            "ActionReporter::NonBaseTestReporter"
          end
        end
        stub_const("ActionReporter::NonBaseTestReporter", non_base_class)

        # Use actual file basename logic to get the class name
        result = described_class.send(:discover_reporter_from_file, "/test/non_base_test_reporter.rb")
        expect(result).to be_nil
      end
    end

    describe ".load_registered_reporter" do
      it "returns nil for non-existent classes" do
        config = {
          class_name: "ActionReporter::NonExistentReporter",
          require_path: "action_reporter/nonexistent_reporter"
        }

        result = described_class.send(:load_registered_reporter, config)
        expect(result).to be_nil
      end

      it "returns nil for classes that don't inherit from Base" do
        non_base_class = Class.new do
          def self.name
            "ActionReporter::NonBaseLoadReporter"
          end
        end
        stub_const("ActionReporter::NonBaseLoadReporter", non_base_class)

        config = {
          class_name: "ActionReporter::NonBaseLoadReporter",
          require_path: "action_reporter/rails_reporter"
        }

        result = described_class.send(:load_registered_reporter, config)
        expect(result).to be_nil
      end

      it "handles missing require_path gracefully" do
        custom_reporter_class = Class.new(ActionReporter::Base) do
          def self.name
            "ActionReporter::NoRequirePathReporter"
          end
        end
        stub_const("ActionReporter::NoRequirePathReporter", custom_reporter_class)

        config = {
          class_name: "ActionReporter::NoRequirePathReporter",
          require_path: nil
        }

        result = described_class.send(:load_registered_reporter, config)
        expect(result).to eq(custom_reporter_class)
      end
    end

    describe ".required?" do
      it "checks if a path is already required" do
        # Test that it checks $LOADED_FEATURES
        expect(described_class.send(:required?, "action_reporter/base")).to be true
        expect(described_class.send(:required?, "nonexistent/path")).to be false
      end
    end
  end
end

RSpec.describe ActionReporter do
  describe ".available_reporters" do
    it "returns discovered reporters" do
      reporters = described_class.available_reporters

      expect(reporters).to be_an(Array)
      expect(reporters).not_to be_empty
      expect(reporters).to include(ActionReporter::RailsReporter)
    end

    it "does not block application boot" do
      # This should return immediately without requiring files
      expect { described_class.available_reporters }.not_to raise_error
    end
  end

  describe ".register_reporter" do
    before do
      ActionReporter::PluginDiscovery.instance_variable_set(:@registered_reporters, {})
    end

    it "registers a custom reporter" do
      described_class.register_reporter(:test, class_name: "ActionReporter::RailsReporter", require_path: "action_reporter/rails_reporter")

      registered = ActionReporter::PluginDiscovery.instance_variable_get(:@registered_reporters)
      expect(registered[:test]).not_to be_nil
    end
  end
end
