# frozen_string_literal: true

require "rubygems"

module ReleaseAppraisalInstall
  TargetRuby = Struct.new(:version, :bundler, keyword_init: true)

  RED = "\033[1;31m"
  GREEN = "\033[0;32m"
  NC = "\033[0m"

  CI_RUBY_BY_APPRAISAL = {
    "rails6" => {ruby: "3.1"},
    "rails72" => {ruby: "3.2"},
    "rails8ruby34" => {ruby: "3.4"},
    "rails8ruby4" => {ruby: "4.0", bundler: "2.7.2"},
    "rails8truffleruby" => {ruby: "truffleruby"}
  }.freeze

  module_function

  def install(execute_command: nil)
    execute_command&.call("bundle exec appraisal generate")

    Dir.glob("gemfiles/*.gemfile").sort.each do |gemfile_path|
      install_gemfile(gemfile_path)
    end
  end

  def install_gemfile(gemfile_path)
    target = target_for_gemfile(gemfile_path)
    gemfile_argument = File.expand_path(gemfile_path)

    run_bundle_command(target, "check", "--gemfile", gemfile_argument) ||
      run_bundle_command(target, "install", "--gemfile", gemfile_argument, "--retry", "1") ||
      exit(1)
  end

  def audit_gemfile(gemfile_path)
    target = target_for_gemfile(gemfile_path)
    environment = {"BUNDLE_GEMFILE" => File.expand_path(gemfile_path)}
    puts "==> #{gemfile_path} (ruby #{target.version})"
    run_bundle_command(target, "exec", "bundle", "audit", "check", environment: environment)
  end

  def target_ruby_for_gemfile(gemfile_path)
    target_for_gemfile(gemfile_path).version
  end

  def target_for_gemfile(gemfile_path)
    appraisal_name = File.basename(gemfile_path, ".gemfile")
    ci_target = CI_RUBY_BY_APPRAISAL[appraisal_name]
    return target_from_ci_config(ci_target, gemfile_path) if ci_target

    target_from_gemfile_requirement(gemfile_path)
  end

  def target_from_ci_config(ci_target, gemfile_path)
    version = resolve_rbenv_version(ci_target.fetch(:ruby), gemfile_path)
    TargetRuby.new(version: version, bundler: ci_target[:bundler])
  end

  def target_from_gemfile_requirement(gemfile_path)
    requirement = ruby_requirement_from_gemfile(gemfile_path)
    return TargetRuby.new(version: RUBY_VERSION) unless requirement

    requirement_object = Gem::Requirement.create(requirement)
    return TargetRuby.new(version: RUBY_VERSION) if requirement_object.satisfied_by?(Gem::Version.new(RUBY_VERSION))

    matching_version = matching_installed_ruby_version(requirement_object)
    return TargetRuby.new(version: matching_version) if matching_version

    raise_missing_ruby(gemfile_path, requirement, installed_rbenv_versions)
  end

  def ruby_requirement_from_gemfile(gemfile_path)
    content = File.read(gemfile_path)
    match = content.match(/^\s*ruby\s+(.+?)\s*$/)
    return unless match

    match[1].strip.delete('"').delete("'")
  end

  def bundler_environment(target)
    environment = {}
    environment["BUNDLER_VERSION"] = target.bundler if target.bundler
    environment
  end

  def resolve_rbenv_version(preferred_ruby, gemfile_path)
    return resolve_truffleruby_version(gemfile_path) if preferred_ruby == "truffleruby"

    matching_version = newest_non_truffleruby_version_for(preferred_ruby)
    return matching_version if matching_version

    raise_missing_ruby(gemfile_path, ">= #{preferred_ruby}.0", installed_rbenv_versions)
  end

  def resolve_truffleruby_version(gemfile_path)
    truffleruby_version = installed_rbenv_versions.find { |version| version.start_with?("truffleruby") }
    return truffleruby_version if truffleruby_version

    raise_missing_ruby(gemfile_path, "truffleruby", installed_rbenv_versions)
  end

  def newest_non_truffleruby_version_for(preferred_ruby)
    installed_rbenv_versions
      .reject { |version| version.start_with?("truffleruby") }
      .select { |version| version.start_with?("#{preferred_ruby}.") || version == preferred_ruby }
      .max_by { |version| Gem::Version.new(version) }
  end

  def matching_installed_ruby_version(requirement_object)
    installed_rbenv_versions
      .reject { |version| version.start_with?("truffleruby") }
      .select { |version| gem_version_satisfies?(requirement_object, version) }
      .max_by { |version| Gem::Version.new(version) }
  end

  def gem_version_satisfies?(requirement_object, version)
    requirement_object.satisfied_by?(Gem::Version.new(version))
  rescue ArgumentError
    false
  end

  def installed_rbenv_versions
    @installed_rbenv_versions ||= begin
      output = `rbenv versions --bare 2>/dev/null`.strip
      output.split("\n").map(&:strip).reject(&:empty?)
    end
  end

  def bundle_command_prefix(target)
    return ["bundle"] if target.version == RUBY_VERSION

    bundle_executable = File.join(rbenv_root, "versions", target.version, "bin", "bundle")
    return [bundle_executable] if File.executable?(bundle_executable)

    raise_missing_ruby(gemfile_path_for_target(target), target.version, installed_rbenv_versions)
  end

  def bundle_executable_for(target)
    bundle_command_prefix(target).join(" ")
  end

  def path_environment_for(target)
    return {} if target.version == RUBY_VERSION

    version_bin = File.join(rbenv_root, "versions", target.version, "bin")
    return {} unless File.directory?(version_bin)

    {"PATH" => "#{version_bin}#{File::PATH_SEPARATOR}#{ENV.fetch("PATH", "")}"}
  end

  def run_bundle_command(target, *command, environment: {})
    command_prefix = bundle_command_prefix(target)
    merged_environment = environment.merge(bundler_environment(target)).merge(path_environment_for(target))
    printable_environment = merged_environment.map { |key, value| "#{key}=#{value}" }.join(" ")
    printable_command = ([printable_environment] + command_prefix + command).reject(&:empty?).join(" ")
    puts "#{GREEN}#{printable_command}#{NC}"

    system(merged_environment, *command_prefix, *command)
  end

  def rbenv_root
    ENV.fetch("RBENV_ROOT", File.expand_path("~/.rbenv"))
  end

  def gemfile_path_for_target(target)
    CI_RUBY_BY_APPRAISAL.find { |_name, config| config[:ruby] == target.version }&.first || "gemfile"
  end

  def raise_missing_ruby(gemfile_path, requirement, installed_versions)
    installed_list = installed_versions.empty? ? "none" : installed_versions.join(", ")
    warn "#{RED}Missing Ruby for #{gemfile_path} (requires #{requirement}). Installed via rbenv: #{installed_list}.#{NC}"
    exit 1
  end
end
