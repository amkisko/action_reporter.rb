module ActionReporter
  class ScoutApmReporter < Base
    class_accessor "ScoutApm::Agent"
    class_accessor "ScoutApm::Context"

    def notify(*args, **kwargs)
      ScoutApm::Agent.instance.error(*args, **kwargs)
    end

    def context(args)
      if args[:audited_user].present?
        ScoutApm::Context.add_user(
          audited_user_global_id: args[:audited_user].to_global_id
        )
      end
      ScoutApm::Context.add(args)
    end

    def reset_context
      ScoutApm::Context.clear!
    end
  end
end
