require_relative "lib/action_reporter/version"

Gem::Specification.new do |gem|
  gem.name = "action_reporter"
  gem.version = ActionReporter::VERSION

  gem.license = "MIT"

  gem.platform = Gem::Platform::RUBY

  repository_url = "https://github.com/amkisko/action_reporter.rb"

  gem.authors = ["Andrei Makarov"]
  gem.email = ["contact@kiskolabs.com"]
  gem.homepage = repository_url
  gem.description = "Ruby wrapper for multiple reporting services"
  gem.summary = "See description"
  gem.metadata = {
    "homepage" => repository_url,
    "source_code_uri" => repository_url,
    "bug_tracker_uri" => "#{repository_url}/issues",
    "changelog_uri" => "#{repository_url}/blob/main/CHANGELOG.md",
    "rubygems_mfa_required" => "true"
  }

  gem.files = Dir.glob("lib/**/*.rb") + Dir.glob("bin/**/*") + %w[CHANGELOG.md LICENSE.md README.md action_reporter.gemspec]

  # s.bindir      = "bin"
  # s.executables = ["action_reporter"]

  gem.required_ruby_version = ">= 2.5.0"
  gem.require_path = "lib"

  gem.add_runtime_dependency "rails", "> 5"

  gem.add_development_dependency "audited", "~> 5"
  gem.add_development_dependency "honeybadger", "~> 5"
  gem.add_development_dependency "sentry-ruby", "~> 5"
  gem.add_development_dependency "scout_apm", "~> 5"
  gem.add_development_dependency "paper_trail", "~> 15"

  gem.add_development_dependency "bundler", "~> 2"
  gem.add_development_dependency "rspec", "~> 3.12"
  gem.add_development_dependency "rspec_junit_formatter", "~> 0.6"
  gem.add_development_dependency "webmock", "~> 3"
  gem.add_development_dependency "pry", "~> 0.14"
  gem.add_development_dependency "simplecov", "~> 0.21"
  gem.add_development_dependency "simplecov-cobertura", "~> 3"
  gem.add_development_dependency "standard", "~> 1.0"
  gem.add_development_dependency "appraisal", "~> 2.4"
  gem.add_development_dependency "rbs", "~> 3.0"
end
