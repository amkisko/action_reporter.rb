require_relative "base"

module ActionReporter
  # Plugin discovery mechanism for auto-discovering reporters
  # This is lazy-loaded to avoid blocking application boot
  module PluginDiscovery
    class << self
      # Initialize class instance variables
      @registered_reporters = nil
      @discovered_reporters = nil
      @discovery_lock = Mutex.new

      # Accessors for class instance variables
      def registered_reporters
        @registered_reporters ||= {}
      end

      attr_reader :discovered_reporters

      attr_writer :discovered_reporters

      def discovery_lock
        @discovery_lock ||= Mutex.new
      end

      # Register a reporter manually (useful for custom reporters)
      # @param name [Symbol] Reporter name
      # @param class_name [String] Fully qualified class name
      # @param require_path [String] Path to require (e.g., "action_reporter/custom_reporter")
      def register(name, class_name:, require_path:)
        discovery_lock.synchronize do
          registered_reporters[name] = {
            class_name: class_name,
            require_path: require_path
          }
        end
      end

      # Discover reporters from the filesystem (lazy-loaded, cached)
      # Only discovers files matching *_reporter.rb pattern in action_reporter/ directory
      # @return [Array<Class>] Array of reporter classes
      def discover
        return discovered_reporters if discovered_reporters

        discovery_lock.synchronize do
          return discovered_reporters if discovered_reporters

          self.discovered_reporters = []
          # __dir__ is lib/action_reporter/, so we're already in the right directory
          base_path = __dir__

          # Discover built-in reporters
          Dir.glob(File.join(base_path, "*_reporter.rb")).each do |file|
            reporter_class = discover_reporter_from_file(file)
            discovered_reporters << reporter_class if reporter_class
          rescue => e
            # Silently skip files that can't be loaded (non-blocking)
            warn "ActionReporter: Failed to discover reporter from #{file}: #{e.message}" if logger
          end

          self.discovered_reporters = discovered_reporters.freeze
        end
      end

      # Get all available reporters (discovered + registered)
      # @return [Array<Class>] Array of reporter classes
      def available_reporters
        reporters = discover.dup

        # Add registered reporters (lazy-loaded)
        registered_configs = discovery_lock.synchronize { registered_reporters.values.dup }
        registered_configs.each do |config|
          reporter_class = load_registered_reporter(config)
          reporters << reporter_class if reporter_class
        rescue => e
          # Silently skip registered reporters that can't be loaded (non-blocking)
          warn "ActionReporter: Failed to load registered reporter #{config[:class_name]}: #{e.message}" if logger
        end

        reporters.uniq.freeze
      end

      # Reset discovery cache (useful for testing)
      def reset!
        discovery_lock.synchronize do
          self.discovered_reporters = nil
        end
      end

      private

      def discover_reporter_from_file(file_path)
        base_name = File.basename(file_path, ".rb")

        # Convert snake_case to PascalCase
        # e.g., "scout_apm_reporter" -> "ScoutApmReporter"
        # e.g., "rails_reporter" -> "RailsReporter"
        class_name = base_name
          .split("_")
          .map(&:capitalize)
          .join

        full_class_name = "ActionReporter::#{class_name}"

        # Lazy load reporter file on discovery.
        # Some callers (including tests) pass synthetic paths that do not exist.
        begin
          require file_path
        rescue LoadError
          # Ignore and continue with constant resolution.
        end

        # Check if class is defined after requiring.
        return nil unless Object.const_defined?(full_class_name)

        klass = Object.const_get(full_class_name)
        return nil unless klass < Base

        klass
      end

      def load_registered_reporter(config)
        # Try to load reporter file first; require is idempotent.
        if config[:require_path]
          begin
            require config[:require_path]
          rescue LoadError => e
            warn "ActionReporter: Could not require #{config[:require_path]}: #{e.message}" if logger
          end
        end

        # Check if class is defined (e.g., file loaded, inline test class, or already loaded)
        return nil unless Object.const_defined?(config[:class_name])

        klass = Object.const_get(config[:class_name])
        return nil unless klass < Base

        klass
      end

      def logger
        ActionReporter.logger
      end
    end
  end
end
