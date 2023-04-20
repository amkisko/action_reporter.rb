require_relative 'error'

module ActionReporter
  class Base
    def self.class_accessor(class_name, gem_spec: nil)
      method_name = class_name.gsub("::", "_").downcase + "_class"
      define_method(method_name) do
        raise ActionReporter::Error.new("#{class_name} is not defined") unless Object.const_defined?(class_name)

        @@class_cache ||= {}
        @@class_cache[class_name] ||= begin
          if gem_spec
            gem_name, version = gem_spec.scan(/([^(\s]+)\s*(?:\(([^)]+)\))?/).first
            latest_spec = Gem.loaded_specs[gem_name]
            version_satisfied = latest_spec && Gem::Requirement.new(version).satisfied_by?(latest_spec.version)
            raise ActionReporter::Error.new("#{gem_spec} is not loaded") if !version_satisfied
          end
          Object.const_get(class_name)
        end
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
        raise ArgumentError.new("Unknown check-in identifier: #{identifier.inspect}")
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
