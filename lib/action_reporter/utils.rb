module ActionReporter
  module Utils
    module_function

    def deep_transform_values(hash, &block)
      hash.each_with_object({}) do |(k, v), result|
        value = if v.is_a?(Hash)
          deep_transform_values(v, &block)
        elsif v.is_a?(Array)
          v.map { |e| e.is_a?(Hash) ? deep_transform_values(e, &block) : e }
        else
          v
        end

        result[k] = block.call(value)
      end
    end
  end
end
