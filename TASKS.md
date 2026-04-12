# Tasks

## P0

- [ ] Detect and surface backend binary failures (stub/exit-0) early in grind startup
  **ID**: detect-backend-stub-exit
  **Tags**: reliability, devin, startup, logging
  **Details**: On 2026-04-12 a Devin CLI update (`2026.4.9-0`) shipped a stub binary (`#!/bin/bash\nexit 0`) instead of a real executable. Taskgrind ran 4 sessions — each lasting 0s with `exit=0` and `shipped=0` — before triggering `fast_fail` and giving up. No diagnostic was emitted to explain the root cause; the operator log just showed `session ended exit=0 duration=0s`. The fix was to roll back the devin symlink manually. Taskgrind should detect this class of silent backend failure at startup: run a quick sanity probe (e.g. `devin --version`) before the first session and abort with a clear, actionable error message if the backend exits in under 1 second with no output. This prevents wasting an entire grind budget on a broken backend.
  **Files**: `bin/taskgrind`, `lib/backend.sh`, `tests/backend.bats`
  **Acceptance**: When the backend binary is a stub that exits immediately, taskgrind aborts before session 1 with a log line like `backend_probe_failed exit=0 duration=0s backend=devin` and a human-readable message suggesting reinstall or rollback; existing passing probe behavior is unchanged; a bats test covers both passing and failing probe paths.

## P1
- [ ] Recover cleanly when git sync rebases across concurrent `TASKS.md` edits
  **ID**: recover-from-tasks-md-sync-conflicts
  **Tags**: git-sync, tasks-md, reliability
  **Details**: The 2026-04-12 `oncall-hub-app` grind logs (`taskgrind-2026-04-12-0806-oncall-hub-app-21210.log` and `taskgrind-2026-04-12-1109-oncall-hub-app-32431.log`) repeatedly show `git_sync rebase_failed` / `git_sync rebase_aborted` because replayed commits hit `TASKS.md` content conflicts while multiple sessions were removing or decomposing task blocks. The same family shows up in the `taskgrind` audit log (`taskgrind-2026-04-12-0806-taskgrind-19844.log`) and the later `bosun` run (`taskgrind-2026-04-12-0807-bosun-22061.log`), where the repo kept looping through the same `TASKS.md` conflict family at 08:34, 09:03, 10:54, and even a later `pre_session_recovery rebase_aborted` at 15:25. Add a conflict-tolerant sync path for `TASKS.md` so routine queue churn does not poison the entire sync cycle.
  **Files**: `bin/taskgrind`, `tests/git-sync.bats`, `tests/session.bats`, `README.md`, `docs/resume-state.md`
  **Acceptance**: A targeted sync test reproduces concurrent `TASKS.md` edits and shows taskgrind preserving local queue changes without leaving the repo mid-rebase; logs explain the recovery path; normal non-conflict sync behavior remains unchanged.

- [ ] Classify git-sync rebase conflicts consistently in operator logs
  **ID**: classify-git-sync-rebase-conflicts
  **Tags**: git-sync, logging, reliability
  **Details**: The 2026-04-12 `agentbrew` log (`taskgrind-2026-04-12-0806-agentbrew-19027.log`) shows `git_sync rebase_failed` on `docs/COMPETITION.md` with no machine-readable conflict class, and the later `bosun` log (`taskgrind-2026-04-12-0807-bosun-22061.log`) repeats raw `TASKS.md` conflict failures without the queue-specific class at 08:34, 09:03, and 10:54 before ending with another unclassified `pre_session_recovery rebase_aborted` at 15:25. Meanwhile the later `oncall-hub-app` log (`taskgrind-2026-04-12-1109-oncall-hub-app-32431.log`) already emits `class=queue_only paths=TASKS.md` for the same rebase-failure family. Make the conflict classification consistent across git-sync and pre-session recovery paths so operators can immediately tell whether a rebase failed on queue churn (`TASKS.md`) or a broader repo conflict that needs manual attention.
  **Files**: `bin/taskgrind`, `tests/git-sync.bats`, `tests/session.bats`, `README.md`
  **Acceptance**: Rebase-failure logs always include a stable conflict class plus the conflicting paths; tests cover both `TASKS.md`-only conflicts and non-queue file conflicts; pre-session recovery and regular git-sync reuse the same logging format.

## P2
## P3
