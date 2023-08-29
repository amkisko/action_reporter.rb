Gem::Specification.new do |gem|
  gem.name = "action_reporter"
  gem.version = File.read(File.expand_path('../lib/action_reporter.rb', __FILE__)).match(/VERSION\s*=\s*'(.*?)'/)[1]

  gem.license = "MIT"

  gem.platform = Gem::Platform::RUBY

  repository_url = "https://github.com/amkisko/action_reporter.rb"

  gem.authors = ["Andrei Makarov"]
  gem.email = ["andrei@kiskolabs.com"]
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

  gem.files = Dir.glob("lib/**/*.rb") + Dir.glob("bin/**/*") + %w(CHANGELOG.md LICENSE.md README.md action_reporter.gemspec)

  # s.bindir      = "bin"
  # s.executables = ["action_reporter"]

  gem.required_ruby_version = ">= 1.9.3"
  gem.require_path = "lib"

  gem.add_development_dependency 'rspec', '~> 3'
  gem.add_development_dependency 'webmock', '~> 3'
  gem.add_development_dependency 'pry-byebug', '~> 3'

  gem.add_runtime_dependency 'rails', '~> 7'
  gem.add_runtime_dependency 'audited', '~> 5'
  gem.add_runtime_dependency 'honeybadger', '~> 5'
  gem.add_runtime_dependency 'sentry-ruby', '~> 5'
  gem.add_runtime_dependency 'scout_apm', '~> 5'
end
