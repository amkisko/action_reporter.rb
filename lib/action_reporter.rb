require 'action_reporter/version'
require 'action_reporter/utils'
require 'action_reporter/base'
require 'action_reporter/rails_reporter'
require 'action_reporter/honeybadger_reporter'
require 'action_reporter/sentry_reporter'
require 'action_reporter/scout_apm_reporter'
require 'action_reporter/audited_reporter'

module ActionReporter
  module_function

  AVAILABLE_REPORTERS = [
    ActionReporter::RailsReporter,
    ActionReporter::HoneybadgerReporter,
    ActionReporter::SentryReporter,
    ActionReporter::ScoutApmReporter,
    ActionReporter::AuditedReporter
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
      new_context =
        reporter.transform_context? ? transform_context(context) : context
      reporter.notify(error, context: new_context)
    end
  end

  def context(args)
    enabled_reporters.each do |reporter|
      new_args = reporter.transform_context? ? transform_context(args) : args
      reporter.context(new_args)
    end
  end

  def reset_context
    enabled_reporters.each(&:reset_context)
  end

  def audited_user
    enabled_reporters.find { |r| r.respond_to?(:audited_user) }&.audited_user
  end

  def transform_context(context)
    ActionReporter::Utils.deep_transform_values(context.except(:audited_user)) do |value|
      if value.respond_to?(:to_global_id)
        value.to_global_id.to_s
      else
        value
      end
    end
  end
end
