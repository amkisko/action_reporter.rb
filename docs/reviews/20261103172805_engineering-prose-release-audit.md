# Engineering and prose audit before 3.2.2 publish

## Participants

Andrei Makarov (@amkisko)

## Decisions

Re-audit main for the unpublished 3.2.2 cut after the 2026-10-28 release-tooling pass. Include ScoutApm reset and notify isolation, Scout ignore-transaction mapping, Sentry nil `transaction_id` tag delete, release confirmation and changelog gates, pull_request CI, and ASCII docs punctuation. Leave tag and RubyGems publish to `make release` after commit.

## Effects

Pipeline: facade -> reporters -> Sentry / ScoutApm / Honeybadger / audit stores / Rails logger. Boundary mode covered identity bind and unbind at those sinks. Resource and identification modes: no new person identifiers in gem logs. Queue, worker, learned-system, and physical plant modes skipped (absent).

Ranked fixes applied:

1. Clear ScoutApm `@user` / `@extra` on `reset_context` (high confidence, observed; prior `clear!` stub was futile).
2. Restore ScoutApm `@extra` after `notify` (high confidence, observed).
3. Delegate `ignore_transaction!` to `ScoutApm::Transaction.ignore!` (high confidence, observed).
4. Delete Sentry `transaction_id` tag on nil setter (medium confidence, observed).
5. Changelog heading and confirmation specs; CHANGELOG dated 2026-11-03.
6. ASCII and badge pass on `spec/README.md` and README fury version query.

Deferred (documented in the issue): nil-user empty-string binds, private Scout/Sentry API coupling, unused error constants.

Checks observed in this session:

- bundle exec rubocop --no-server on 8 touched Ruby files: no offenses.
- bundle exec rbs validate: ok.
- bundle exec rspec: 214 examples, 0 failures.
- POLYRUN_COVERAGE=1 polyrun parallel-rspec --workers 5 --merge-failures: exit 0; coverage/merged-summary.txt 99.56% lines (456 / 458) across 13 files.
- gem build action_reporter.gemspec and Gem::Package#verify for 3.2.2: ok (19 packaged files).
- usr/reports/resource_smoke.rb 10_000 ops: ~0.031 CPU seconds, 1464 retained heap bytes (under 1s / 1 MiB budgets).
- Re-audit after Scout/Sentry/release fixes: ship; no remaining confirmed actionable findings in those paths.

## Next

Commit, then `make release`.

## Source

- docs/issues/20261103172805_engineering-prose-release-audit.md
- CHANGELOG.md section 3.2.2 (2026-11-03)
- Prior pass: docs/issues/20261028093000_engineering-release-audit.md
