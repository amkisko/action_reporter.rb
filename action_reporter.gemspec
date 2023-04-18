Gem::Specification.new do |s|
  s.name = "action_reporter"
  s.version = "1.0.2"

  s.license = "MIT"

  s.platform = Gem::Platform::RUBY

  s.authors = ["Andrei Makarov"]
  s.email = ["andrei@kiskolabs.com"]
  s.homepage = "https://github.com/amkisko/action_reporter"
  s.description = "Ruby wrapper for multiple reporting services"
  s.summary = "See description"
  s.metadata = {
    "homepage" => "https://github.com/amkisko/action_reporter",
    "source_code_uri" => "https://github.com/amkisko/action_reporter",
    "bug_tracker_uri" => "https://github.com/amkisko/action_reporter/issues",
    "changelog_uri" => "https://github.com/amkisko/action_reporter/blob/main/CHANGELOG.md",
    "rubygems_mfa_required" => "true"
  }

  s.files = Dir.glob("lib/**/*.rb") + Dir.glob("bin/**/*") + %w(CHANGELOG.md LICENSE.md README.md action_reporter.gemspec)

  # s.bindir      = "bin"
  # s.executables = ["action_reporter"]

  s.required_ruby_version = ">= 1.9.3"
  s.require_path = "lib"
end
