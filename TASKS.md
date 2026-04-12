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

- [ ] Stop audit-only queue refresh sessions from spinning without removing a task
  **ID**: stop-audit-only-zero-ship-loops
  **Tags**: prompting, tasks-md, reliability
  **Details**: The 2026-04-12 `taskgrind` audit logs (`taskgrind-2026-04-12-0806-taskgrind-19844.log` sessions 21-25 and `taskgrind-2026-04-12-0806-taskgrind-20411.log` session 36) show repeated audit-only sessions that committed `TASKS.md` note refreshes, explicitly said they did not remove any task block, and still consumed full sessions as `productive_zero_ship reason=local_task_churn` or `reason=no_local_task_removed`. Add a guardrail so a focus like “analyze logs and update tasks” either maps to an explicit removable audit task block or exits before burning sessions on queue-maintenance-only commits that cannot satisfy the completion protocol.
  **Files**: `bin/taskgrind`, `tests/session.bats`, `tests/signals.bats`, `README.md`
  **Acceptance**: A failing test reproduces an audit-only instruction that would previously commit `TASKS.md` note churn without deleting a task block; taskgrind now either refuses the run with a clear operator log or routes it through a dedicated removable audit task; logs no longer show repeated queue-refresh sessions ending with “I did not remove any task block from TASKS.md” for the same focus.

## P2
## P3
