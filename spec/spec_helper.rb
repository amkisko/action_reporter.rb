require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
  add_filter { |source_file| source_file.lines.count < 5 }
end

require "simplecov-cobertura"
SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter

require "webmock/rspec"

require "action_reporter"

Dir[File.expand_path("support/**/*.rb", __dir__)].each { |f| require_relative f }

RSpec.configure do |config|

end
