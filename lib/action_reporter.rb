require "action_reporter/utils"
require "action_reporter/base"
require "action_reporter/rails_reporter"
require "action_reporter/honeybadger_reporter"
require "action_reporter/sentry_reporter"
require "action_reporter/scout_apm_reporter"
require "action_reporter/audited_reporter"
require "action_reporter/paper_trail_reporter"

module ActionReporter
  module_function

  VERSION = "1.5.2".freeze

  AVAILABLE_REPORTERS = [
    ActionReporter::RailsReporter,
    ActionReporter::HoneybadgerReporter,
    ActionReporter::SentryReporter,
    ActionReporter::ScoutApmReporter,
    ActionReporter::AuditedReporter,
    ActionReporter::PaperTrailReporter
  ].freeze

  @enabled_reporters = []

  def enabled_reporters=(reporters)
    @enabled_reporters = reporters
  end

  def enabled_reporters
    @enabled_reporters
  end

  def notify(error, context: {})
    enabled_reporters.each do |reporter|
      next unless reporter.respond_to?(:notify)

      reporter.notify(error, context: context)
    end
  end

  def context(args)
    enabled_reporters.each do |reporter|
      next unless reporter.respond_to?(:context)

      reporter.context(args)
    end
  end

  def reset_context
    enabled_reporters.each do |reporter|
      next unless reporter.respond_to?(:reset_context)

      reporter.reset_context
    end
  end

  def current_user
    @current_user
  end

  def current_user=(user)
    @current_user = user
    enabled_reporters.each do |reporter|
      next unless reporter.respond_to?(:current_user=)

      reporter.current_user = user
    end
  end

  def current_request_uuid
    @current_request_uuid
  end

  def current_request_uuid=(request_uuid)
    @current_request_uuid = request_uuid
    enabled_reporters.each do |reporter|
      next unless reporter.respond_to?(:current_request_uuid=)

      reporter.current_request_uuid = request_uuid
    end
  end

  def current_remote_addr
    @current_remote_addr
  end

  def current_remote_addr=(remote_addr)
    @current_remote_addr = remote_addr
    enabled_reporters.each do |reporter|
      next unless reporter.respond_to?(:current_remote_addr=)

      reporter.current_remote_addr = remote_addr
    end
  end

  def check_in(identifier)
    enabled_reporters.each do |reporter|
      next unless reporter.respond_to?(:check_in)

      reporter.check_in(identifier)
    end
  end
end
