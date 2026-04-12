# Tasks

## P0

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

- [ ] Keep test backend execution working when audit helpers inject non-executable commands
  **ID**: harden-test-backend-command-resolution
  **Tags**: testing, audit, reliability
  **Details**: The audit-helper logs `taskgrind-2026-04-12-1404-repo-70059.log` and `taskgrind-2026-04-12-1410-repo-94203.log` both hard-fail every session with `/Users/fivanishche/apps/taskgrind/bin/taskgrind: line 986: /bin/true: No such file or directory`. Those runs execute against temporary repos under `/var/folders/.../repo`, so a bad `DVB_GRIND_CMD` or helper command is being passed straight into `run_test_backend()` without any preflight or normalization. Harden the test-backend path so audit and check helpers can safely inject simple commands without collapsing the whole grind into an instant zero-ship loop.
  **Files**: `bin/taskgrind`, `tests/session.bats`, `tests/diagnostics.bats`, `README.md`
  **Acceptance**: A failing test reproduces the temporary-repo helper path with a non-executable or malformed injected command; taskgrind reports a clear actionable error instead of spinning through repeated `/bin/true` launch failures; valid `DVB_GRIND_CMD` test flows still behave exactly as before.

## P2
## P3
