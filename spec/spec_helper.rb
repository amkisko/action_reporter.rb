polyrun_cov_measure =
  ENV["POLYRUN_COVERAGE_DISABLE"] != "1" &&
  %w[1 true yes].include?(ENV["POLYRUN_COVERAGE"]&.to_s&.downcase)

if polyrun_cov_measure
  require "coverage"
  branch = %w[1 true yes].include?(ENV["POLYRUN_COVERAGE_BRANCHES"]&.to_s&.downcase)
  ::Coverage.start(lines: true, branches: branch)
end

if polyrun_cov_measure
  require "polyrun/coverage/rails"
  Polyrun::Coverage::Rails.start!(root: File.expand_path("..", __dir__))
end

# Require logger for Ruby 3.1+ compatibility (Logger is no longer in stdlib)
require "logger"

require "action_reporter"

Dir[File.expand_path("support/**/*.rb", __dir__)].each { |f| require_relative f }

RSpec.configure do |config|
end
require "polyrun/rspec"
Polyrun::RSpec.install_sharded_formatter_compat!
Polyrun::RSpec.install_failure_fragments!
Polyrun::RSpec.install_worker_ping!
Polyrun::RSpec.install_example_debug!
Polyrun::RSpec.install_example_rails_logging!
Polyrun::RSpec.install_example_timeout!
Polyrun::RSpec.install_example_prosopite!
if %w[1 true yes].include?(ENV["POLYRUN_SPEC_QUALITY"]&.to_s&.downcase)
  Polyrun::RSpec.install_spec_quality!
end
