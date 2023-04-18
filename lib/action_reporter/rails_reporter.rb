module ActionReporter
  class RailsReporter < Base
    class_accessor "Rails"

    def notify(error, context: {})
      new_context = transform_context(context)
      Rails.logger.info(
        "Reporter notification: #{error.inspect}, #{new_context.inspect}"
      )
    end

    def context(args)
      new_context = transform_context(args)
      Rails.logger.info("Reporter context: #{new_context.inspect}")
    end
  end
end
