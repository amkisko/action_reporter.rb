module ActionReporter
  class HoneybadgerReporter < Base
    class_accessor "Honeybadger"

    def notify(error, context: {})
      new_context = transform_context(context)
      Honeybadger.notify(error, context: new_context)
    end

    def context(args)
      new_context = transform_context(args)
      Honeybadger.context(new_context)
    end

    def reset_context
      Honeybadger.context.clear!
    end
  end
end
