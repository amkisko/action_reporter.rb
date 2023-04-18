module ActionReporter
  class RailsReporter < Base
    class_accessor "Rails"

    def notify(error, context: {})
      Rails.logger.info(
        "Reporter notification: #{error.inspect}, #{context.inspect}"
      )
    end

    def context(args)
      Rails.logger.info("Reporter context: #{args.inspect}")
    end

    def reset_context
    end
  end
end
