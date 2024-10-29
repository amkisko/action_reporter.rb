module ActionReporter
  class HoneybadgerReporter < Base
    class_accessor "Honeybadger", gem_spec: "honeybadger (~> 5)"

    def notify(error, context: {})
      new_context = transform_context(context)
      honeybadger_class.notify(error, context: new_context)
    end

    def context(args)
      new_context = transform_context(args)
      honeybadger_class.context(new_context)
    end

    def reset_context
      honeybadger_class.context.clear!
    end

    def check_in(identifier)
      check_in_id = resolve_check_in_id(identifier)
      honeybadger_class.check_in(check_in_id)
    end

    def current_user=(user)
      honeybadger_class.context(user_global_id: user.to_global_id.to_s) if user
    end
  end
end
