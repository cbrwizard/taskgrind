# Tasks

## P0
- [ ] Document the productive-timeout auto-increase behavior across all docs
  **ID**: doc-productive-timeout-auto-increase
  **Tags**: docs, accuracy, operator-facing
  **Details**: When a session ships work but hits the `TG_MAX_SESSION` timeout, taskgrind silently increases `max_session` by 1800 s (capped at 7200 s / 2 h) so the next session gets more runway. This behavior is not mentioned anywhere: the README feature bullet says only "detects when timeout kills sessions that were shipping", the man page `TG_MAX_SESSION` entry says only "Max seconds per session before timeout (default: 3600)", `docs/architecture.md` does not cover the rationale, and no user story shows the auto-increase log line. An operator who sets `TG_MAX_SESSION=3600` expecting a hard 1 h cap would be surprised by sessions running up to 2 h. Add the auto-increase behavior, its 7200 s ceiling, and the `productive_timeout` log marker to: the README feature bullet and env var table note, the man page `TG_MAX_SESSION` entry, a new architecture.md section explaining the design trade-off, and a brief mention in the user stories monitoring or troubleshooting context.
  **Files**: `README.md`, `man/taskgrind.1`, `docs/architecture.md`, `docs/user-stories.md`
  **Acceptance**: All four docs explain that `TG_MAX_SESSION` can auto-increase after a productive timeout, state the 7200 s cap, and mention the `productive_timeout` log marker. Existing tests in `tests/user-stories-docs.bats` or `tests/basics.bats` still pass.

- [ ] Document the diminishing-returns detection mechanism behind `TG_EARLY_EXIT_ON_STALL`
  **ID**: doc-diminishing-returns-mechanism
  **Tags**: docs, accuracy, operator-facing
  **Details**: The implementation tracks shipped counts in a rolling 5-session window and warns when throughput drops below 2 tasks in that window. If `TG_EARLY_EXIT_ON_STALL=1`, taskgrind exits. None of the docs explain the window size, threshold, warning output, or the `diminishing_returns` log marker. The README env var table says only "Exit on low throughput (1=enabled)" and the man page says "Exit early on low throughput (default: 0, 1 to enable)". Operators cannot understand what "low throughput" means or predict when the guard fires. Add the rolling-window parameters and warning behavior to: the README env var description and a brief note in the Features list, the man page `TG_EARLY_EXIT_ON_STALL` entry, a new architecture.md section explaining the design rationale, and a user story or troubleshooting entry showing what the warning and early exit look like.
  **Files**: `README.md`, `man/taskgrind.1`, `docs/architecture.md`, `docs/user-stories.md`
  **Acceptance**: All four docs explain the 5-session rolling window, the <2-shipped threshold, the warning output, and the `diminishing_returns` log marker. The env var description in the README and man page gives operators enough information to decide whether to enable the guard.

- [ ] Add `status:` field to user-stories dry-run example and align with actual output
  **ID**: doc-dry-run-status-field
  **Tags**: docs, accuracy
  **Details**: The actual `--dry-run` output prints a `status:` line showing the `TG_STATUS_FILE` path or `disabled` (line 884 of `bin/taskgrind`), but user story 6 omits it from the example output. Add `status:   disabled` to the dry-run example in `docs/user-stories.md` between the `log:` and `notify:` lines so the example matches what a user actually sees.
  **Files**: `docs/user-stories.md`
  **Acceptance**: The dry-run example in story 6 includes the `status:` field and matches the actual output of `taskgrind --dry-run` for a run without `TG_STATUS_FILE`.

- [ ] Correct the README blocked-queue feature bullet to describe the wait-and-retry behavior
  **ID**: doc-blocked-queue-wait-behavior
  **Tags**: docs, accuracy, operator-facing
  **Details**: The README Features list says "**Blocked-queue detection** — exits early when all remaining tasks have `**Blocked by**:` metadata" but the implementation actually waits 600 s (10 min, capped at remaining deadline) for an external unblock, extends the deadline by the wait duration so no time budget is lost, re-checks the queue, and only then exits if still blocked. The wait, deadline extension, `blocked_wait` status phase, and re-check are all omitted. Update the feature bullet and add a brief mention in the troubleshooting table so operators know the grind will pause before giving up.
  **Files**: `README.md`
  **Acceptance**: The README blocked-queue bullet and troubleshooting table reflect the wait duration, deadline extension, and re-check behavior. The `blocked_wait` phase is mentioned as a healthy-idle state consistent with the status-file docs.

- [ ] Document the 3-attempt per-task retry cap and skip-list behavior so operators can predict when stuck tasks get skipped
  **ID**: doc-per-task-retry-cap
  **Tags**: docs, accuracy, operator-facing, task-attempts
  **Details**: taskgrind tracks per-task attempt counts via task ID and, after 3 unsuccessful attempts (no ship), prepends a "SKIP these stuck tasks" list to the next session's prompt (`bin/taskgrind` around line 2200–2206). Shipping a task resets its counter. The architecture doc mentions the ID-based tracking but neither README nor man page explains the 3-attempt cap, the skip list, or the `task_attempt_cap_reached` log marker. An operator seeing the same task fail repeatedly cannot predict when taskgrind will start skipping it or understand the unfamiliar prompt injection. Add this to the Features list, the relevant env var description (there is no dedicated env var today — document whether the 3 is configurable or a constant), and a user story showing the skip-list appearing in a session prompt.
  **Files**: `README.md`, `man/taskgrind.1`, `docs/architecture.md`, `docs/user-stories.md`
  **Acceptance**: README + man page explain the 3-attempt cap, the skip-list injection, the counter-reset on ship, and the `task_attempt_cap_reached` log marker. If the cap is configurable via an env var, that var is documented alongside other `TG_` knobs; if it is a constant, the docs say so explicitly.

## P1

- [ ] An operator pressing Ctrl+C during a long grind has a user story showing what they will see
  **ID**: doc-graceful-shutdown-user-story
  **Tags**: docs, shutdown, user-stories, operator-facing
  **Details**: The README mentions "Graceful shutdown — SIGINT/SIGTERM waits for running session, pushes commits, ignores duplicate shutdown signals, then exits", and the code implements a 120 s grace period (`TG_SHUTDOWN_GRACE`, validated at `bin/taskgrind:236`) plus a 15 s per-session grace (`TG_SESSION_GRACE`, validated at `bin/taskgrind:239`) before force-kill. `docs/user-stories.md` does not show what the terminal looks like from the moment the operator hits ^C to the final "grind_done" summary — when the grind is safe to rerun, what the log says, how duplicate ^C is ignored. Add a story (e.g., "Interrupting a grind with Ctrl+C") walking through the happy path and the timeout path with sample output.
  **Files**: `docs/user-stories.md`, `README.md`
  **Acceptance**: A new user-stories entry shows: (1) the "Waiting for session to finish" message, (2) the grace-period countdown, (3) session finishes vs. times out, (4) final summary line, (5) sample log lines with `graceful_shutdown` markers, (6) when it's safe to rerun. `tests/user-stories-docs.bats` still passes.

## P2
- [ ] Add canonical `TG_` precedence tests for wait and backoff env vars that only have validation coverage
  **ID**: expand-tg-precedence-coverage
  **Tags**: tests, env, compatibility
  **Details**: The repo migration to canonical `TG_` env vars is covered for many knobs, but some settings such as `TG_EMPTY_QUEUE_WAIT` still only have invalid-value tests. Add focused precedence coverage for the remaining wait/backoff-style knobs so future refactors do not silently prefer the legacy `DVB_` alias.
  **Files**: `tests/diagnostics.bats`, `tests/network.bats`, `tests/session.bats`
  **Acceptance**: The affected env vars have red/green coverage proving `TG_` overrides the matching `DVB_` value during a real run, not just in validation error paths.

- [ ] `all_tasks_blocked()` has direct unit-style test coverage across TASKS.md edge cases
  **ID**: test-all-tasks-blocked-coverage
  **Tags**: tests, blocking, queue-state
  **Details**: `all_tasks_blocked()` (`bin/taskgrind:1804`) decides whether every task has a `**Blocked by**:` and drives the blocked-wait path. Today it is only exercised indirectly through `session.bats` asserting log output. Direct coverage would catch regressions like a malformed `**Blocked by**:` being counted as a block or an unblocked task being missed. Add tests that call the function against fixture TASKS.md files: empty queue, single blocked task, mixed blocked/unblocked, malformed metadata, `**Blocked**:` (reason-only) vs. `**Blocked by**:` (dependency) — and verify return code plus counter output.
  **Files**: `tests/session.bats`, `tests/features.bats`
  **Acceptance**: New tests exercise six scenarios (empty, all-blocked, single-blocked, mixed, malformed, reason-vs-dependency) with clear expected return codes. `make check` passes.

- [ ] `wait_for_network()` deadline-extension and timeout behavior is covered by focused tests
  **ID**: test-wait-for-network-coverage
  **Tags**: tests, network, resilience
  **Details**: `wait_for_network()` (`bin/taskgrind:1835`) pauses the marathon timer, polls for recovery, extends the deadline by the actual wait duration, and returns 1 when `TG_NET_MAX_WAIT` is exceeded. `tests/network.bats` covers the integration but not the deadline-extension math or the `network_timeout` / `network_restored` / `waiting_for_network` phase transitions. Add focused tests so a refactor that drops the extension or swaps the phase marker gets caught.
  **Files**: `tests/network.bats`
  **Acceptance**: Tests verify (1) deadline increases by exactly the wait duration on recovery, (2) function exits 0 on recovery, (3) exits 1 and logs `network_timeout` past `TG_NET_MAX_WAIT`, (4) phase marker is `waiting_for_network` during the wait and `network_restored` on recovery.

- [ ] `detect_default_branch()` has test coverage for each fallback rung
  **ID**: test-detect-default-branch-coverage
  **Tags**: tests, git, sync
  **Details**: `detect_default_branch()` (`bin/taskgrind:1608`) walks `origin/HEAD` → `ls-remote --symref` → upstream → local → `main` → `master`. `tests/git-sync.bats` covers the happy integration path. A missed fallback rung would manifest as "rebase failed — unknown branch" in production. Add tests that set up repo fixtures for each rung and verify the function returns the expected branch plus logs which method was used.
  **Files**: `tests/git-sync.bats`
  **Acceptance**: Each of the six fallbacks has a test that forces that rung to fire and asserts the returned branch name plus the detection-method log marker.

- [ ] `auto_resolve_tasks_rebase_conflicts()` has focused tests for the TASKS.md-only path
  **ID**: test-auto-resolve-tasks-conflicts
  **Tags**: tests, git, rebase, conflict-resolution
  **Details**: `auto_resolve_tasks_rebase_conflicts()` (`bin/taskgrind:1765`) keeps the local TASKS.md when a rebase conflict touches only that file, preventing the queue-churn deadlock. `tests/git-sync.bats` tests the end-to-end sync; the function itself has no direct coverage. A bug here (e.g., accidentally auto-resolving conflicts in other files) would silently drop changes. Add tests for: (1) TASKS.md-only conflict is auto-resolved, (2) TASKS.md + another file conflict is NOT auto-resolved, (3) local TASKS.md content is preserved, (4) log line `auto_resolve_tasks_conflicts` appears.
  **Files**: `tests/git-sync.bats`
  **Acceptance**: Four targeted tests exercise the auto-resolve path directly against fixture git repos.

- [ ] Boolean `TG_*` env vars reject non-0/1 values with an actionable error message
  **ID**: test-early-exit-stall-validation
  **Tags**: tests, validation, error-messages
  **Details**: Numeric `TG_*` vars like `TG_COOL` and `TG_MAX_SESSION` are validated with clear errors (`bin/taskgrind:216–240`). `TG_EARLY_EXIT_ON_STALL` is used as a boolean (`if [[ ... == "1" ]]`) with no up-front validation, so `TG_EARLY_EXIT_ON_STALL=yes` silently means "disabled". Add validation after line 240 rejecting non-0/1 with a clear error (`must be 0 or 1, got 'X'`), matching the existing pattern. Add tests in `tests/diagnostics.bats`.
  **Files**: `bin/taskgrind`, `tests/diagnostics.bats`
  **Acceptance**: (1) `TG_EARLY_EXIT_ON_STALL=yes taskgrind ~/repo` exits 1 with a clear error; (2) `0` and `1` still work; (3) same pattern applied to any other boolean `TG_*` knob that today accepts garbage. Tests pin the behavior.

## P3

- [ ] Error messages for common failures include actionable next-step guidance
  **ID**: test-error-message-quality
  **Tags**: tests, error-messages, ux
  **Details**: Several taskgrind error paths surface a reason but not a remediation. Examples: `Error: --model requires a name` (line 161) doesn't show a valid model; `Backend binary not found (devin)` (line 664) doesn't point at install docs. Most users see these once and bounce. Raise the floor by covering 5+ error paths with tests that assert each message mentions (a) what went wrong, (b) what to do next, (c) a doc link or example where relevant. The test itself becomes the spec for "a good error message" in this repo.
  **Files**: `tests/diagnostics.bats`, `bin/taskgrind`
  **Acceptance**: At least five error paths (missing backend, invalid model, invalid numeric env var, missing repo path, unsupported backend) have tests asserting the error includes both the cause and an actionable next step. Any new error path added after this task is expected to pass the same pattern.
