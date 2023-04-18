module ActionReporter
  class SentryReporter < Base
    class_accessor "Sentry"

    def notify(error, context: {})
      Sentry.with_scope do |temp_scope|
        transform_context(context).each do |key, value|
          temp_scope.set_context(key, value)
        end

        if error.is_a?(StandardError)
          Sentry.capture_exception(error)
        else
          Sentry.capture_message(error)
        end
      end
    end

    def context(args)
      transform_context(args).each do |key, value|
        Sentry.get_current_scope.set_context(key, value)
      end
    end

    def audited_user=(user)
      Sentry.set_user(global_id: user.to_global_id.to_s) if user
    end
  end
end
