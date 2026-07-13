module ActionReporter
  class ScoutApmReporter < Base
    class_accessor "ScoutApm::Error"
    class_accessor "ScoutApm::Context"

    def notify(error, context: {})
      self.context(context)
      scoutapm_error_class.capture(error)
    end

    def context(args)
      context_object = scoutapm_context_class.current
      extra = context_object.instance_variable_get(:@extra).dup
      # ScoutApm::Context.add ignores nil values and has no per-key delete API; replace @extra directly.
      context_object.instance_variable_set(:@extra, merge_context_updates(extra, args))
    end

    def reset_context
      scoutapm_context_class.clear! if scoutapm_context_class.respond_to?(:clear!)
    end

    def current_remote_addr=(remote_addr)
      scoutapm_context_class.add_user(ip: remote_addr)
    end

    def current_user=(user)
      id = resolve_user_id(user)
      scoutapm_context_class.add_user(id: id)
    end

    def ignore_transaction!
      scoutapm_context_class.ignore_transaction!
    end
  end
end
