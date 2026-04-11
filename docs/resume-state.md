# Resumable Grind State

This note defines the contract for `taskgrind --resume` before the runtime work lands. The goal is to let future implementation changes share one state schema and one set of compatibility rules instead of re-deciding them in code, tests, and docs.

## Goals

- Preserve enough state to continue the same grind after an interruption.
- Refuse ambiguous or stale state instead of silently mixing two different runs.
- Keep the saved contract small so operators can inspect it and tests can assert it directly.

## State file shape

Taskgrind should write one JSON file per repo under a deterministic path derived from the absolute repo path. The file should contain:

- `schema_version` — increments when the on-disk contract changes.
- `saved_at` — timestamp of the most recent write.
- `repo` — absolute repo path the state belongs to.
- `repo_git_dir` — absolute git dir path when available, used to reject copied repos or moved worktrees.
- `deadline_epoch` — original active deadline to continue against.
- `hours_requested` — original requested grind length for diagnostics.
- `session` — completed session counter.
- `tasks_shipped` — total shipped tasks so far.
- `sessions_zero_ship` — total zero-ship sessions so stall logic survives restart.
- `consecutive_zero_ship` — current live zero-ship streak.
- `consecutive_fast` — current fast-failure streak.
- `backend` — active backend name.
- `skill` — active skill name.
- `model` — startup model baseline for the grind.
- `startup_model` — explicit copy of the baseline model shown to the operator.
- `extra_prompt` — startup prompt text so resumed sessions inherit the same baseline instructions.
- `sync_interval` — persisted so resume does not silently change git sync cadence.
- `max_session` — persisted to avoid resuming into a different watchdog contract.
- `task_attempts` — map of task ID to retry count so skip logic survives restart.
- `last_session_summary` — human-readable summary reused in the next prompt.
- `last_session_result` — `success`, `failure`, or `pending`.
- `last_session_completed_at` — timestamp of the most recent completed session.

The file should stay append-free: each write replaces the whole JSON blob atomically.

## When taskgrind writes state

Taskgrind should update the state file at these points:

- After startup configuration is finalized and before the first session starts.
- After each session finishes and counters are updated.
- After network-wait deadline extension is applied.
- Before process exit on explicit interrupt, watchdog timeout, or unrecoverable failure.

This keeps `--resume` aligned with the last durable session boundary rather than trying to snapshot every transient variable mid-command.

## Resume validation rules

`taskgrind --resume` should load state only when all of these checks pass:

- The file exists and parses as valid JSON.
- `schema_version` matches a supported reader version.
- `repo` matches the current absolute repo path.
- `repo_git_dir`, when present, matches the current git dir path.
- `deadline_epoch` is still in the future.
- The saved backend and skill still resolve in the current install.
- The state file is newer than the repo's last clean completion marker, if one exists.

Resume should reject the file with a clear error when:

- The schema version is unknown.
- The repo path or git dir do not match.
- The deadline already expired.
- The file is missing required counters or contains malformed numeric values.
- The saved backend/model/skill are no longer valid enough to launch.

On rejection, taskgrind should tell the operator why resume was refused and how to start a fresh grind instead.

## Cleanup and invalidation rules

Taskgrind should remove or invalidate resume state when:

- The grind exits normally because the queue is empty.
- The grind exits normally because the deadline is reached.
- The operator starts a fresh run without `--resume`, which should overwrite any old state with a new grind identity.

Taskgrind should keep the state file when:

- The operator interrupts the run and wants to continue later.
- A session fails in a way that aborts the grind early.
- The machine loses power or the parent shell disappears.

If explicit deletion is risky during failure handling, writing an `invalidated_at` or `completed_at` marker is acceptable as long as `--resume` treats that state as closed.

## Operator flow

Fresh run:

1. `taskgrind ~/apps/myrepo 8`
2. Taskgrind creates or refreshes the per-repo resume file as the grind progresses.
3. If the run finishes cleanly, taskgrind removes or invalidates the file.

Resumed run:

1. `taskgrind --resume ~/apps/myrepo`
2. Taskgrind loads the saved state, validates it, and prints a short restore banner.
3. Session numbering, shipped counts, stall counters, backend, skill, model, and deadline continue from the saved state.
4. If validation fails, taskgrind exits with a clear message and suggests starting a fresh run.

## Testing implications

The runtime implementation should make these cases easy to verify:

- Saving state after a successful session updates counters and timestamps.
- Resume restores counters, deadline, backend, skill, and model.
- Stale or incompatible state is rejected without mutating the current repo.
- Clean completion invalidates the state so a later `--resume` does not restart an already-finished grind.
