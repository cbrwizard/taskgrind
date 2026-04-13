# Tasks

## P0
## P1
- [ ] Continue the operator-docs CLI example audit after the `--model` prose fix
  **ID**: continue-cli-doc-example-audit
  **Tags**: docs, audit, user-stories
  **Details**: Finish auditing the remaining README, man page, and user-stories command snippets for uncaught example drift so future docs-only sessions have a clear follow-up once the `--model` prose regression is covered.
  **Files**: `README.md`, `docs/user-stories.md`, `man/taskgrind.1`, `TASKS.md`
  **Acceptance**: Any newly discovered CLI example drift is captured as concrete follow-up tasks or fixed directly with updated regression coverage.
## P2
- [ ] Add canonical `TG_` precedence tests for wait and backoff env vars that only have validation coverage
  **ID**: expand-tg-precedence-coverage
  **Tags**: tests, env, compatibility
  **Details**: The repo migration to canonical `TG_` env vars is covered for many knobs, but some settings such as `TG_EMPTY_QUEUE_WAIT` still only have invalid-value tests. Add focused precedence coverage for the remaining wait/backoff-style knobs so future refactors do not silently prefer the legacy `DVB_` alias.
  **Files**: `tests/diagnostics.bats`, `tests/network.bats`, `tests/session.bats`
  **Acceptance**: The affected env vars have red/green coverage proving `TG_` overrides the matching `DVB_` value during a real run, not just in validation error paths.
## P3
