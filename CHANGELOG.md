# CHANGELOG

## 2.0.0 (2025-11-05)

- Add performance benchmarks to measure CPU, memory, and response-time impact
  - Benchmarks wall-time overhead for context + notify + reset operations
  - Tests with 0 to 10 reporters to show scaling behavior
  - Shows overhead per reporter (~1.5ms per reporter on average)
  - Helps estimate response-time impact based on number of enabled reporters
- BREAKING: Complete rewrite of plugin discovery system
  - New lazy-loaded plugin discovery that auto-discovers reporters from filesystem
  - Introduced `ActionReporter::PluginDiscovery` module for managing reporter discovery
  - `AVAILABLE_REPORTERS` constant maintained for backward compatibility but `available_reporters` method is now preferred
  - Plugin discovery does not block application boot - all discovery is lazy-loaded
- BREAKING: Thread safety changes - context attributes are now thread-safe
  - Replace module-level instance variables with thread-local storage using `ActionReporter::Current`
  - Context attributes (`current_user`, `current_request_uuid`, `current_remote_addr`) are now thread-safe
  - Prevents data leakage and race conditions in multi-threaded environments
  - Maintains API compatibility but behavior is now thread-safe
- Add custom reporter registration support
  - New `ActionReporter.register_reporter(name, class_name:, require_path:)` method
  - Allows third-party gems and applications to register custom reporters (e.g., Datadog, New Relic)
  - Registered reporters automatically appear in `available_reporters`
  - Supports both file-based and inline-defined reporters
- Add `ActionReporter.available_reporters` method to get all available reporters (discovered + registered)
- Add thread-safe plugin discovery with Mutex-based caching
- Add comprehensive error handling to all reporter methods
  - Reporter failures no longer break the entire reporting chain
  - Errors are logged but don't prevent other reporters from executing
  - Added `ActionReporter.logger` for configurable error logging (defaults to `Rails.logger` if available)
  - Added `ActionReporter.error_handler` for custom error handling callbacks
- Fix `reset_context` method to properly reset instance attributes (`@current_user`, `@current_request_uuid`, `@current_remote_addr`)
- Improve error handling in plugin discovery - gracefully handles missing files, invalid classes, and load errors
- Add `ActionReporter::PluginDiscovery.reset!` method for testing purposes
- Add thread safety tests
- Add error handling tests with fault isolation verification
- Add comprehensive plugin discovery tests
- Add custom reporter registration tests
- Achieve 100% test coverage (297/297 lines)

## 1.5.2 (2024-12-13)

- Add Audited context support

## 1.5.1 (2024-10-29)

- Fix Audited current user setter to use `audited_user`

## 1.5.0 (2024-10-29)

- BREAKING: Rename `audited_user` to `current_user`
- Add `current_request_uuid` and `current_remote_addr` getters and setters
- Memoize `current_user`, `current_request_uuid`, and `current_remote_addr`

## 1.4.1 (2024-02-02)

- Add paper_trail support

## 1.4.0 (2023-08-30)

- Set minimum ruby version requirement to 2.5.0

## 1.3.2 (2023-08-29)

## 1.3.1 (2023-08-29)

- Update gem configuration

## 1.3.0 (2023-08-15)

- Update ruby version to 3.2.2
- Update dependencies to latest

## 1.2.0 (2023-04-20)

- Major fixes for class resolvers
- Implemented ActionReporter::Error class
- Improved test coverage

## 1.1.1 (2023-04-18)

- Update check-in logic

## 1.1.0 (2023-04-18)

- Add reporter check-in method

## 1.0.7 (2023-04-18)

- Moving Sentry context under `context` key

## 1.0.6 (2023-04-18)

- Possible fix for Sentry context setting

## 1.0.5 (2023-04-18)

- Fix Sentry reporting and context setting

## 1.0.4 (2023-04-18)

- Move `transform_context` to individual reporter classes

## 1.0.3 (2023-04-18)

- Fix scoutapm notice method

## 1.0.2 (2023-04-18)

- Add ruby version support for versions lower than 3.2.0

## 1.0.1 (2023-04-18)

- Fix scoutapm reset_context method
- Update README notes

## 1.0.0 (2023-04-18)

- Initial version
