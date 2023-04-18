module ActionReporter
  class ScoutApmReporter < Base
    class_accessor "ScoutApm::Agent"
    class_accessor "ScoutApm::Context"

    def notify(*args, **kwargs)
      ScoutApmAgent.instance.error(*args, **kwargs)
    end

    def context(args)
      ScoutApmContext.add(args)
    end
  end
end
