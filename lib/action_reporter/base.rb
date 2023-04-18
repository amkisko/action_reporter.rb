module ActionReporter
  class Base
    def self.class_accessor(class_name)
      return unless Object.const_defined?(class_name)

      const_name = class_name.gsub("::", "")
      const_set(const_name, Object.const_get(class_name))
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

    def notify(*)
    end

    def context(*)
    end

    def reset_context
    end
  end
end
