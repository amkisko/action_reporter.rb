module ActionReporter
  class ScoutApmReporter < Base
    class_accessor "ScoutApm::Error"
    class_accessor "ScoutApm::Context"

    def notify(error, context: {})
      self.context(context)
      ScoutApmError.capture(error)
    end

    def context(args)
      new_context = transform_context(args)
      ScoutApmContext.add(new_context)
    end
  end
end
