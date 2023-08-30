require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'
  add_filter { |source_file| source_file.lines.count < 5 }
end

require 'simplecov-cobertura'
SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
