# Tasks

## P0
- [ ] Turn final-sync edge cases into behavior-tested guarantees
  **ID**: behavior-test-final-sync-edge-cases
  **Tags**: testing, git, reliability
  **Details**: Final push protection is critical for unattended runs, but some `final_sync` paths are still mostly covered structurally instead of by realistic git behavior. Add bats coverage for duplicate-push suppression, nothing-to-push exits, and push-failure diagnostics so taskgrind can be trusted to shut down cleanly without extra operator babysitting.
  **Files**: `bin/taskgrind`, `tests/signals.bats`, `tests/git-sync.bats`
  **Acceptance**: Bats tests exercise real final-sync outcomes for duplicate attempts, zero-ahead shutdowns, and rejected pushes, and the resulting log/output expectations are locked in.
## P1
- [ ] Refresh dry-run user-story output to match the current default stall guard (@devin)
  **ID**: refresh-dry-run-user-story-output
  **Tags**: docs, audit
  **Details**: `docs/user-stories.md` still shows `early_exit_on_stall: 1` in the dry-run sample even though taskgrind now defaults that setting to `0` unless the operator opts in. Update the sample so the user story mirrors live output and does not imply that stall exits are enabled by default.
  **Files**: `docs/user-stories.md`
  **Acceptance**: The dry-run sample in `docs/user-stories.md` matches current default output for the stall guard, and a fresh `taskgrind --dry-run` check confirms the documented value.
## P2
- [ ] Add canonical `TG_` precedence tests for wait and backoff env vars that only have validation coverage
  **ID**: expand-tg-precedence-coverage
  **Tags**: tests, env, compatibility
  **Details**: The repo migration to canonical `TG_` env vars is covered for many knobs, but some settings such as `TG_EMPTY_QUEUE_WAIT` still only have invalid-value tests. Add focused precedence coverage for the remaining wait/backoff-style knobs so future refactors do not silently prefer the legacy `DVB_` alias.
  **Files**: `tests/diagnostics.bats`, `tests/network.bats`, `tests/session.bats`
  **Acceptance**: The affected env vars have red/green coverage proving `TG_` overrides the matching `DVB_` value during a real run, not just in validation error paths.
## P3
