module ActionReporter
  class ScoutApmReporter < Base
    class_accessor "ScoutApm::Error"
    class_accessor "ScoutApm::Context"
    class_accessor "ScoutApm::Transaction"

    def notify(error, context: {})
      context_object = scoutapm_context_class.current
      previous_extra = context_object.instance_variable_get(:@extra).dup
      begin
        self.context(context)
        scoutapm_error_class.capture(error)
      ensure
        context_object.instance_variable_set(:@extra, previous_extra)
      end
    end

    def context(args)
      context_object = scoutapm_context_class.current
      extra = context_object.instance_variable_get(:@extra).dup
      # ScoutApm::Context.add ignores nil values and has no per-key delete API; replace @extra directly.
      context_object.instance_variable_set(:@extra, merge_context_updates(extra, args))
    end

    def reset_context
      context_object = scoutapm_context_class.current
      # ScoutApm::Context no longer exposes clear!; wipe request-local user and extra hashes.
      context_object.instance_variable_set(:@extra, {})
      context_object.instance_variable_set(:@user, {})
    end

    def current_remote_addr=(remote_addr)
      scoutapm_context_class.add_user(ip: remote_addr)
    end

    def current_user=(user)
      id = resolve_user_id(user)
      scoutapm_context_class.add_user(id: id)
    end

    def ignore_transaction!
      scoutapm_transaction_class.ignore!
    end
  end
end
