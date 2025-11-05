module ActionReporter
  class Error < StandardError; end

  # Raised when there's a configuration issue (e.g., missing gem, invalid setup)
  class ConfigurationError < Error; end

  # Raised when a reporter encounters an error during operation
  class ReporterError < Error; end
end
