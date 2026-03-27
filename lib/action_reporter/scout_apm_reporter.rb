module ActionReporter
  class ScoutApmReporter < Base
    class_accessor "ScoutApm::Error", gem_spec: "scout_apm (~> 5)"
    class_accessor "ScoutApm::Context", gem_spec: "scout_apm (~> 5)"

    def notify(error, context: {})
      self.context(context)
      scoutapm_error_class.capture(error)
    end

    def context(args)
      new_context = transform_context(args)
      scoutapm_context_class.add(new_context)
    end

    def current_remote_addr=(remote_addr)
      scoutapm_context_class.add_user(ip: remote_addr)
    end

    def current_user=(user)
      return if user.nil?

      id = resolve_user_id(user)
      scoutapm_context_class.add_user(id: id)
    end

    def ignore_transaction!
      scoutapm_context_class.ignore_transaction!
    end
  end
end
