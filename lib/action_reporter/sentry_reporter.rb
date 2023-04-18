module ActionReporter
  class SentryReporter < Base
    class_accessor "Sentry"

    def notify(error, context: {})
      self.context(context)
      Sentry.capture_exception(error)
    end

    def context(args)
      args.each do |key, value|
        Sentry.configure_scope { |scope| scope.set_context(key, value) }
      end
    end

    def reset_context
      Sentry.configure_scope { |scope| scope.clear_breadcrumbs }
    end
  end
end
