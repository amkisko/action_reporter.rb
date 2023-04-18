module ActionReporter
  class ScoutApmReporter < Base
    class_accessor "ScoutApm::Error"
    class_accessor "ScoutApm::Context"

    def notify(error, context: {})
      self.context(context)
      ScoutApmError.capture(error)
    end

    def context(args)
      ScoutApmContext.add(args)
    end
  end
end
