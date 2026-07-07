# Testing

## Commands

Full suite (matches CI: parallel shards via Polyrun):

```bash
make test
```

Lint (RuboCop and RBS):

```bash
make lint
```

Focused runs:

```bash
bundle exec rspec spec/action_reporter_spec.rb
bundle exec rspec spec/performance/
```

See [POLYRUN.md](../POLYRUN.md) and `polyrun.yml`. `make test` runs `hooks.before_suite` before specs.

## Layout

- `spec/` — unit specs for reporter configuration and instrumentation
- `spec/performance/` — optional benchmark-style specs (metrics cops excluded in RuboCop)

## Guidelines

- Test observable reporting outcomes, not internal dispatch details.
- Mock only external boundaries (Sentry, logging backends, time).
- Add or update specs before bugfixes; run `make lint && make test` before a PR.
- Coverage threshold: `config/polyrun_coverage.yml` when `POLYRUN_COVERAGE=1`.
