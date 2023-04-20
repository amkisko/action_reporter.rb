module ActionReporter
  class SentryReporter < Base
    class_accessor "Sentry"

    def notify(error, context: {})
      sentry_class.with_scope do |temp_scope|
        temp_scope.set_context("context", transform_context(context))

        if error.is_a?(StandardError)
          sentry_class.capture_exception(error)
        else
          sentry_class.capture_message(error)
        end
      end
    end

    def context(args)
      sentry_class.get_current_scope.set_context("context", transform_context(args))
    end

    def reset_context
      sentry_class.get_current_scope.set_context("context", {})
    end

    def audited_user=(user)
      sentry_class.set_user(user_global_id: user&.to_global_id&.to_s)
    end
  end
end
