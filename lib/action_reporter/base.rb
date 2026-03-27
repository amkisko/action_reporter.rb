require_relative "error"

module ActionReporter
  class Base
    def self.class_accessor(class_name, gem_spec: nil)
      method_name = class_name.gsub("::", "_").downcase + "_class"
      define_method(method_name) do
        raise ActionReporter::Error.new("#{class_name} is not defined") unless Object.const_defined?(class_name)

        # Use instance variable instead of class variable for thread safety
        # Each class gets its own cache, avoiding cross-class contamination
        @class_cache ||= {}
        @class_cache[class_name] ||= Object.const_get(class_name)
      end
    end

    def transform_context(context)
      ActionReporter::Utils.deep_transform_values(context) do |value|
        if value.respond_to?(:to_global_id)
          value.to_global_id.to_s
        else
          value
        end
      end
    end

    def resolve_check_in_id(identifier)
      if identifier.respond_to?(:reporter_check_in)
        identifier.reporter_check_in
      elsif identifier.respond_to?(:to_s)
        identifier.to_s
      else
        raise ActionReporter::Error.new("Unknown check-in identifier: #{identifier.inspect}")
      end
    end

    def notify(*)
    end

    def context(*)
    end

    def reset_context
    end

    def transaction_id=(transaction_id)
    end

    def transaction_name=(transaction_name)
    end

    def resolve_user_id(user)
      resolver = ActionReporter.user_id_resolver
      if resolver.respond_to?(:call)
        resolver.call(user)
      else
        default_resolve_user_id(user)
      end
    end

    private

    def default_resolve_user_id(user)
      if defined?(::GlobalID) && user.is_a?(::GlobalID)
        user.to_s
      elsif defined?(::ActiveRecord::Base) && user.is_a?(::ActiveRecord::Base)
        (user.try(:to_global_id) || user.try(:id)).to_s
      elsif user.respond_to?(:to_global_id)
        user.to_global_id.to_s
      else
        user.to_s
      end
    end
  end
end
