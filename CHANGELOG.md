# CHANGELOG

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
