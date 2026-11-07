# Engineering and release audit

## Decisions

Prepare 3.2.2 as a patch release on main. Keep the initial uncommitted documentation and release changes. Do not commit, tag, push or publish.

Review core behavior, executable tests, GitHub Actions, packaging, resource budgets, trace/privacy, security, contracts and release checks. Inspect external-service boundaries with synthetic fixtures. There is no application UI, independently operated worker, learned system, cloud deployment, physical plant, IPC or message broker in this library, so those surface-specific modes do not apply. CLI diagnostics are assessed through executable tests where present; no visual screen was changed.

## Effects

All listed fixes have high confidence and observed evidence from failing-then-passing executable tests or built-package inspection. Core findings are medium severity except package size and redundant reads, which are low. The smallest repair is described with each finding; no structural rewrite was needed.

- SentryReporter#reset_context retained the previous user's identity and transaction name/tag. Clear those values while preserving unrelated tags. Regression: one example reproduced all three retained fields.
- Release confirmation converted EOF to an empty affirmative answer. Add ReleaseVersionCheck.confirm_release? and reject EOF while preserving an entered empty line and y. Four examples cover EOF, entered default, y and n. The release script uses the checked helper; no publish command was executed.

Confirmed privacy finding: medium severity, high confidence; caller supplies the first request's identity, reset is the isolation boundary, Sentry scope is the sink, and a subsequent request can inherit that identity without a reset. Likelihood depends on scope reuse; demonstrated impact is retained identity and transaction fields. Fingerprint: retained-identity:SentryReporter.reset_context:Sentry-scope. Independent review confirmed the source trace and the bounded regression result.

Enable the test workflow on pull requests and set contents: read; previously the tests started only after a main push or manual dispatch. Third-party actions are pinned by commit. Workflow YAML, triggers, permissions and matrix paths were inspected locally; hosted GitHub Actions were not run.

Checks with Ruby 4.0.2 on arm64 macOS:

- POLYRUN_COVERAGE=1 make test: exit 0, including RuboCop, RBS validation and five test workers.
- bundle exec rspec --format progress: 210 examples, zero failures, zero pending.
- Coverage merge: 99.33% (447/450) tracked lines. Coverage is evidence for those assertions, not proof of all behavior.
- gem build action_reporter.gemspec --output tmp/action_reporter-release.gem, followed by Gem::Package#verify: pass. 17408 compressed bytes, 19 packaged files. Version, changelog heading and path-package lock entries agree.
- git diff --check: pass. Branch remains main.

Resource fixtures are local and use synthetic values. Cold `bundle exec ruby -Ilib -raction_reporter -e 'puts "loaded"'`, measured with `env time -l`: 0.19 CPU seconds and 26968064 bytes maximum RSS. This includes Bundler startup. Audit ceilings are one CPU second and 100 MiB RSS per cold load; both pass. No claim is made about other machines or co-located production services.

The 10,000-operation fixture in usr/reports/resource_smoke.rb measured 0.033785 wall seconds, 0.033487 CPU seconds, 170062 allocated objects and 1464 retained heap bytes after GC. The fixture budget is one CPU second and 1 MiB retained heap growth; both pass. CPU seconds are the energy proxy; no energy meter was available. These loops perform no file writes or network calls. Network-facing unit tests stub service responses; no live provider traffic or credentials were used. Persistent diagnostic and credential paths were inspected separately from these zero-IO loops.

Re-audit: checked the corrected failure paths, consumers, release metadata, package contents, negative tests and final diff. No remaining confirmed actionable finding was identified in the reviewed paths. This is a bounded local audit; live provider behavior, Ruby 3.4 and hosted matrix execution remain outside the measured run.

## Next

Superseded by docs/issues/20261103172805_engineering-prose-release-audit.md (ScoutApm isolation and prose re-audit before publish).

## Source

- AGENTS.md and .agents/skills/engineering-audit/.
- .agents/skills/changelog-update/.
- CHANGELOG.md, spec/, .github/workflows/test.yml and usr/reports/resource_smoke.rb.
