module ActionReporter
  class ScoutApmReporter < Base
    class_accessor "ScoutApm::Agent"
    class_accessor "ScoutApm::Context"

    def notify(*args, **kwargs)
      ScoutApmAgent.instance.error(*args, **kwargs)
    end

    def context(args)
      if args[:audited_user].present?
        ScoutApmContext.add_user(
          audited_user_global_id: args[:audited_user].to_global_id
        )
      end
      ScoutApmContext.add(args)
    end

    def reset_context
      ScoutApmContext.clear!
    end
  end
end
