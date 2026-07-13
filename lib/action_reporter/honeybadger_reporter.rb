module ActionReporter
  class HoneybadgerReporter < Base
    class_accessor "Honeybadger"

    def notify(error, context: {})
      new_context = transform_context(context)
      honeybadger_class.notify(error, context: new_context)
    end

    def context(args)
      current = honeybadger_class.get_context || {}
      merged = merge_context_updates(current, args)
      honeybadger_class.context.clear!
      honeybadger_class.context(merged) unless merged.empty?
    end

    def reset_context
      honeybadger_class.context.clear!
    end

    def check_in(identifier)
      check_in_id = resolve_check_in_id(identifier)
      honeybadger_class.check_in(check_in_id)
    end

    def current_user=(user)
      id = resolve_user_id(user)
      honeybadger_class.context(user_id: id)
    end
  end
end
