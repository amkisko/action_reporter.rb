module ActionReporter
  class Base
    def self.class_accessor(name)
      return unless Object.const_defined?(name)

      const_set(name, Object.const_get(name))
    end

    def transform_context?
      true
    end
  end
end
