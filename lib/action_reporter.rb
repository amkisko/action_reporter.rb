require "action_reporter/version"
require "action_reporter/utils"
require "action_reporter/base"
require "action_reporter/current"
require "action_reporter/rails_reporter"
require "action_reporter/honeybadger_reporter"
require "action_reporter/sentry_reporter"
require "action_reporter/scout_apm_reporter"
require "action_reporter/audited_reporter"
require "action_reporter/paper_trail_reporter"

module ActionReporter
  module_function

  AVAILABLE_REPORTERS = [
    ActionReporter::RailsReporter,
    ActionReporter::HoneybadgerReporter,
    ActionReporter::SentryReporter,
    ActionReporter::ScoutApmReporter,
    ActionReporter::AuditedReporter,
    ActionReporter::PaperTrailReporter
  ].freeze

  @enabled_reporters = []
  @logger = nil
  @error_handler = nil

  def enabled_reporters=(reporters)
    @enabled_reporters = reporters || []
  end

  def enabled_reporters
    @enabled_reporters || []
  end

  def logger
    @logger || ((defined?(Rails) && Rails.respond_to?(:logger)) ? Rails.logger : nil)
  end

  def logger=(logger)
    @logger = logger
  end

  def error_handler
    @error_handler
  end

  def error_handler=(handler)
    @error_handler = handler
  end

  def handle_reporter_error(reporter, error, method_name)
    error_message = "ActionReporter: #{reporter.class}##{method_name} failed: #{error.class} - #{error.message}"

    if logger
      logger.error(error_message)
      logger.debug(error.backtrace.join("\n")) if error.backtrace
    end

    if error_handler&.respond_to?(:call)
      error_handler.call(error, reporter, method_name)
    end
  rescue => e
    # If error handling itself fails, log to stderr as last resort
    warn "ActionReporter: Error handler failed: #{e.message}"
  end

  def notify(error, context: {})
    enabled_reporters.each do |reporter|
      next unless reporter.respond_to?(:notify)

      begin
        reporter.notify(error, context: context)
      rescue => e
        handle_reporter_error(reporter, e, "notify")
      end
    end
  end

  def context(args)
    enabled_reporters.each do |reporter|
      next unless reporter.respond_to?(:context)

      begin
        reporter.context(args)
      rescue => e
        handle_reporter_error(reporter, e, "context")
      end
    end
  end

  def reset_context
    Current.current_user = nil
    Current.current_request_uuid = nil
    Current.current_remote_addr = nil

    enabled_reporters.each do |reporter|
      next unless reporter.respond_to?(:reset_context)

      begin
        reporter.reset_context
      rescue => e
        handle_reporter_error(reporter, e, "reset_context")
      end
    end

    # Reset Current attributes if supported
    Current.reset if Current.respond_to?(:reset)
  end

  def current_user
    Current.current_user
  end

  def current_user=(user)
    Current.current_user = user
    enabled_reporters.each do |reporter|
      next unless reporter.respond_to?(:current_user=)

      begin
        reporter.current_user = user
      rescue => e
        handle_reporter_error(reporter, e, "current_user=")
      end
    end
  end

  def current_request_uuid
    Current.current_request_uuid
  end

  def current_request_uuid=(request_uuid)
    Current.current_request_uuid = request_uuid
    enabled_reporters.each do |reporter|
      next unless reporter.respond_to?(:current_request_uuid=)

      begin
        reporter.current_request_uuid = request_uuid
      rescue => e
        handle_reporter_error(reporter, e, "current_request_uuid=")
      end
    end
  end

  def current_remote_addr
    Current.current_remote_addr
  end

  def current_remote_addr=(remote_addr)
    Current.current_remote_addr = remote_addr
    enabled_reporters.each do |reporter|
      next unless reporter.respond_to?(:current_remote_addr=)

      begin
        reporter.current_remote_addr = remote_addr
      rescue => e
        handle_reporter_error(reporter, e, "current_remote_addr=")
      end
    end
  end

  def check_in(identifier)
    enabled_reporters.each do |reporter|
      next unless reporter.respond_to?(:check_in)

      begin
        reporter.check_in(identifier)
      rescue => e
        handle_reporter_error(reporter, e, "check_in")
      end
    end
  end
end
