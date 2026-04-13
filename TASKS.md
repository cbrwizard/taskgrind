# Tasks

## P0
- [ ] Turn final-sync edge cases into behavior-tested guarantees
  **ID**: behavior-test-final-sync-edge-cases
  **Tags**: testing, git, reliability
  **Details**: Final push protection is critical for unattended runs, but some `final_sync` paths are still mostly covered structurally instead of by realistic git behavior. Add bats coverage for duplicate-push suppression, nothing-to-push exits, and push-failure diagnostics so taskgrind can be trusted to shut down cleanly without extra operator babysitting.
  **Files**: `bin/taskgrind`, `tests/signals.bats`, `tests/git-sync.bats`
  **Acceptance**: Bats tests exercise real final-sync outcomes for duplicate attempts, zero-ahead shutdowns, and rejected pushes, and the resulting log/output expectations are locked in.
## P1
- [ ] Support paired execution and discovery lanes without a sacrificial audit task
  **ID**: paired-execution-discovery-lanes
  **Tags**: workflow, queue, docs, tests
  **Details**: The `apps/ideas` stack already treats `standing-audit-gap-loop` as the discovery lane and `taskgrind` as the execution lane, but operators trying to run that as two concurrent grinds still end up parking a repo-local `standing-audit-gap-loop` task in `TASKS.md`. That task is removed on completion, which is correct for real work items but makes the discovery lane self-destruct. Keep taskgrind narrow, but add a supported two-stream operator story once `tasks.md` lands the reusable standing-loop pattern and targeted `/next-task` behavior it is already tracking: slot 0 keeps shipping normal queue work, slot 1 keeps filling the queue with high-value discoveries, and the flow no longer depends on a permanent removable sentinel task.
  **Files**: `README.md`, `docs/user-stories.md`, `tests/session.bats`, `tests/multi-instance.bats`
  **Acceptance**: Taskgrind documents one supported two-stream workflow for a single repo; tests cover the discovery-lane guard with the standardized standing-loop pattern instead of a sacrificial repo-local task; the docs explain how discovered tasks flow back into the normal execution lane without the standing definition disappearing.

## P2
- [ ] Add canonical `TG_` precedence tests for wait and backoff env vars that only have validation coverage
  **ID**: expand-tg-precedence-coverage
  **Tags**: tests, env, compatibility
  **Details**: The repo migration to canonical `TG_` env vars is covered for many knobs, but some settings such as `TG_EMPTY_QUEUE_WAIT` still only have invalid-value tests. Add focused precedence coverage for the remaining wait/backoff-style knobs so future refactors do not silently prefer the legacy `DVB_` alias.
  **Files**: `tests/diagnostics.bats`, `tests/network.bats`, `tests/session.bats`
  **Acceptance**: The affected env vars have red/green coverage proving `TG_` overrides the matching `DVB_` value during a real run, not just in validation error paths.
## P3
