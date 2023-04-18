module ActionReporter
  class HoneybadgerReporter < Base
    class_accessor "Honeybadger"

    def notify(error, context: {})
      Honeybadger.notify(error, context: context)
    end

    def context(args)
      Honeybadger.context(args)
    end

    def reset_context
      Honeybadger.context.clear!
    end
  end
end
