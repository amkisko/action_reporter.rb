module ActionReporter
  class RailsReporter < Base
    class_accessor "Rails"

    def notify(error, context: {})
      new_context = transform_context(context)
      rails_class.logger.info(
        "Reporter notification: #{error.inspect}, #{new_context.inspect}"
      )
    end

    def context(args)
      new_context = transform_context(args)
      rails_class.logger.info("Reporter context: #{new_context.inspect}")
    end

    def check_in(identifier)
      check_in_id = resolve_check_in_id(identifier)
      rails_class.logger.info("Reporter check-in: #{check_in_id}")
    end
  end
end
