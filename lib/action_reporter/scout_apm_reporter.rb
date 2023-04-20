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

    def audited_user=(user)
      scoutapm_context_class.add_user(user_global_id: user&.to_global_id&.to_s)
    end
  end
end
