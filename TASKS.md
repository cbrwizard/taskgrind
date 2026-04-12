# Tasks

## P0

## P1
- [ ] Detect the repo's real default branch during git sync instead of assuming `main`
  **ID**: detect-default-branch-during-sync
  **Tags**: git-sync, reliability, multi-repo
  **Details**: The 2026-04-12 `ideas` grind log (`taskgrind-2026-04-12-0806-ideas-17272.log`) kept hitting `git_sync checkout_failed: error: pathspec 'main' did not match any file(s) known to git` throughout the day, not just during the early sessions: the same failure kept recurring through the afternoon all the way to the 15:05 entry, and the companion `taskgrind` log (`taskgrind-2026-04-12-0806-taskgrind-19844.log`) recorded the same hard-coded-branch failure when an empty-queue recovery pass tried to bounce back onto the repo default branch after queue churn. Taskgrind still hard-codes `main` in at least one sync or recovery path, which breaks repos whose primary branch is something else. Teach sync to resolve the repo's default branch from git metadata or the current upstream branch before checkout/rebase, while preserving explicit overrides for tests.
  **Files**: `bin/taskgrind`, `tests/git-sync.bats`, `README.md`, `docs/architecture.md`
  **Acceptance**: Git sync succeeds in a repo whose primary branch is not `main`; targeted tests cover auto-detecting the branch name; docs describe the branch-selection behavior and any override escape hatch.

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

- [ ] Surface the root stash failure instead of only logging `stash_pop_failed`
  **ID**: surface-git-stash-failures
  **Tags**: git-sync, logging, reliability
  **Details**: The 2026-04-12 `agentbrew` log (`taskgrind-2026-04-12-0806-agentbrew-19027.log`) and `bosun` log (`taskgrind-2026-04-12-0807-bosun-22061.log`) both hit repeated `git_sync stash_pop_failed (stash preserved)` lines without the original `git stash` error. The agentbrew run hit it at least twice (12:03 and 13:33), while the bosun run hit the same opaque message multiple times again later in the day (11:51, 14:29, and 15:07), so the operator still cannot tell whether the stash command failed, the pop failed after a successful stash, or dirty-state bookkeeping was wrong. Teach git sync to log the actual stash failure reason and only attempt `stash pop` when a stash was created successfully.
  **Files**: `bin/taskgrind`, `tests/git-sync.bats`, `README.md`
  **Acceptance**: Git-sync logs the original stash failure stderr when stash creation fails; `stash pop` is skipped unless a stash was actually created; targeted tests cover both stash-create failure and stash-pop failure paths without regressing normal dirty-tree sync.

## P2
- [ ] Document `make audit` in the main development command list (@instance-1)
  **ID**: document-make-audit-in-dev-commands
  **Tags**: docs, maintenance, audit
  **Details**: The repo now has a local `make audit` workflow and multiple docs describe what it does, but the main development command list in `README.md` still skips that command. New contributors scanning the common dev commands can miss the fastest local audit entrypoint even though it is part of the supported maintenance workflow.
  **Files**: `README.md`, `tests/basics.bats`
  **Acceptance**: The README development command list includes `make audit`; a regression test fails before the doc change and passes after it.
## P3
