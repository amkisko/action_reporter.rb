module ActionReporter
  module Utils
    module_function

    def deep_transform_values(value, &block)
      case value
      when Hash
        value.each_with_object({}) do |(k, v), result|
          result[k] = deep_transform_values(v, &block)
        end
      when Array
        value.map { |element| deep_transform_values(element, &block) }
      else
        block.call(value)
      end
    end
  end
end
