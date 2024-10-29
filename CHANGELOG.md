# 1.5.0

* BREAKING: Rename `audited_user` to `current_user`
* Add `current_request_uuid` and `current_remote_addr` getters and setters
* Memoize `current_user`, `current_request_uuid`, and `current_remote_addr`

# 1.4.1

* Add paper_trail support

# 1.4.0

* Set minimum ruby version requirement to 2.5.0

# 1.3.1

* Update gem configuration

# 1.3.0

* Update ruby version to 3.2.2
* Update dependencies to latest

# 1.2.0

* Major fixes for class resolvers
* Implemented ActionReporter::Error class
* Improved test coverage

# 1.1.1

* Update check-in logic

# 1.1.0

* Add reporter check-in method

# 1.0.7

* Moving Sentry context under `context` key

# 1.0.6

* Possible fix for Sentry context setting

# 1.0.5

* Fix Sentry reporting and context setting

# 1.0.4

* Move `transform_context` to individual reporter classes

# 1.0.3

* Fix scoutapm notice method

# 1.0.2

* Add ruby version support for versions lower than 3.2.0

# 1.0.1

* Fix scoutapm reset_context method
* Update README notes

# 1.0.0

* Initial version
