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

    def check_in(identifier)
      check_in_id = resolve_check_in_id(identifier)
      Honeybadger.check_in(check_in_id)
    end
  end
end
