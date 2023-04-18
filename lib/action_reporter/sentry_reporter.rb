module ActionReporter
  class SentryReporter < Base
    class_accessor "Sentry"

    def notify(error, context: {})
      self.context(context)
      Sentry.capture_exception(error)
    end

    def context(args)
      new_context = transform_context(args)
      Sentry.set_context(args)
    end

    def audited_user=(user)
      Sentry.set_user(global_id: user.to_global_id.to_s) if user
    end
  end
end
