# Engineering, prose, and release audit

## Participants

Andrei Makarov (@amkisko)

## Decisions

- Keep version 3.2.2. Fold ScoutApm isolation fixes and release-gate coverage into the unpublished cut and date the product changelog 2026-11-07.
- Treat ScoutApm `reset_context` like the Sentry isolation boundary: clear `@user` and `@extra` on the request-local context object.
- Keep notify context ephemeral for ScoutApm by restoring prior `@extra` after capture.
- Map `ignore_transaction!` to `ScoutApm::Transaction.ignore!`.
- Delete the Sentry `transaction_id` tag when the setter receives `nil`.
- Keep release confirmation EOF as rejection, require a CHANGELOG version heading, and run tests on pull requests.
- Leave empty-string identity binds for `current_user = nil`, private-API coupling to Scout/Sentry internals, and unused `ConfigurationError` / `ReporterError` types as follow-up work.

## Effects

Pipeline: facade setters / `context` / `notify` / `transaction` / `reset_context` -> reporter adapters -> SDK sinks (Sentry scope, ScoutApm Context, Honeybadger context, Audited/PaperTrail/ActiveVersion stores, Rails logger). Boundary mode covered identity bind/unbind at those sinks. Resource and identification modes: no new person identifiers in gem logs. Queue, worker, learned-system, and physical plant modes skipped (absent).

Ranked fixes applied:

1. ScoutApm `reset_context` clears user and extra hashes (high, observed).
2. ScoutApm `notify` restores prior extra context after capture (high, observed).
3. ScoutApm `ignore_transaction!` calls `ScoutApm::Transaction.ignore!` (medium, observed).
4. Sentry `transaction_id=` deletes the tag on `nil` (low, observed).
5. Release changelog heading and confirmation specs; CHANGELOG dated 2026-11-07 (medium, observed).
6. ASCII punctuation in `spec/README.md`; README gem badge version (house prose).

Deferred:

- `current_user = nil` still binds empty-string ids on Sentry / Honeybadger / Scout.
- Private IV / protected setter coupling to Scout and Sentry internals.
- Unused `ConfigurationError` / `ReporterError` constants.

Checks: rubocop clean on touched files; rspec 214 examples, 0 failures; coverage 99.56% (456/458); gem 3.2.2 builds and verifies.

## Next

- Commit the worktree, then run `make release` for tag and gem push.
- Follow-up: clear-user path for nil `current_user`; reduce private Scout/Sentry API surface where public APIs exist.

## Source

docs/reviews/20261103172805_engineering-prose-release-audit.md
CHANGELOG.md section 3.2.2 (2026-11-07)
docs/changelogs/20261107113305_release-3-2-2-cut.md
docs/issues/20261028093000_engineering-release-audit.md
