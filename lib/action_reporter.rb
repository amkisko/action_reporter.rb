require 'action_reporter/utils'
require 'action_reporter/base'
require 'action_reporter/rails_reporter'
require 'action_reporter/honeybadger_reporter'
require 'action_reporter/sentry_reporter'
require 'action_reporter/scout_apm_reporter'
require 'action_reporter/audited_reporter'
require 'action_reporter/paper_trail_reporter'

module ActionReporter
  module_function

  VERSION = '1.4.1'.freeze

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

  def audited_user
    enabled_reporters.find { |r| r.respond_to?(:audited_user) }&.audited_user
  end

  def audited_user=(user)
    enabled_reporters.each do |reporter|
      next unless reporter.respond_to?(:audited_user=)

      reporter.audited_user = user
    end
  end

  def check_in(identifier)
    enabled_reporters.each do |reporter|
      next unless reporter.respond_to?(:check_in)

      reporter.check_in(identifier)
    end
  end
end
