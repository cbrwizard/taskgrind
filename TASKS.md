# Tasks

<!-- policy: keep runtime files /bin/bash 3.2 compatible (guarded by tests/bash-compat.bats) -->
<!-- policy: run `make check` before claiming a task complete; remove the task block in the same commit that ships the fix -->

## P2

- [ ] Research: emit taskgrind session traces in a format that an external SkillClaw evolve server can consume
  - **ID**: research-skillclaw-session-export
  - **Tags**: research, integration, skillclaw, post-mortem, skill-evolution
  - **Details**: SkillClaw ([github.com/AMAP-ML/SkillClaw](https://github.com/AMAP-ML/SkillClaw), 1k stars, MIT, first OSS release 2026-04-10) is a skill-evolution system that turns session traces into evolved `SKILL.md` files via two engines (`workflow`: 3-stage LLM pipeline, `agent`: OpenClaw-driven). Today, **taskgrind already captures rich session data** — primary log at `$TMPDIR/taskgrind-<date>-<repo>-<pid>.log` (retained by the cleanup routine at `bin/taskgrind:871-881` precisely so `grind-log-analyze` can post-mortem it), session-output files, attempt tracking, sweep results. The gap is format and target: SkillClaw expects OpenAI-compatible chat-completions traces; taskgrind logs are stdout/stderr captures plus structured `*_done` markers (`session_done`, `sweep_done`, `grind_done`).
    **What's worth researching** (not building yet — this is a spike):
    1. **Format gap**: can taskgrind emit a sidecar `session_trace.jsonl` per session in SkillClaw's expected format, or is the gap too wide? SkillClaw's storage layer abstracts `local`, `oss`, `s3` (config: `sharing.backend local` + `sharing.local_root /path`) — so a local-only feed is the cheapest first attempt. The session trace would need: prompt text, tool calls, tool results, final assistant message, per-turn metadata. Some of this is already in the log; some (per-turn boundaries) requires backend-specific parsing.
    2. **Backend coverage**: taskgrind supports `devin`, `claude-code`, and `codex` backends (`README.md` table). Each has a different log format. Determine which one(s) emit enough structure to produce a SkillClaw trace without a heavy adapter:
       - `devin`: produces a session URL + structured event log. Probably feedable.
       - `claude-code`: stdout-streamed assistant text + tool calls. Probably feedable with a parser.
       - `codex`: similar to claude-code. Probably feedable with a parser.
       The adapter cost should be ≤1 day per backend; if it's more, this is a build, not a wrapper.
    3. **Evolution loop fit**: SkillClaw's evolve server consumes sessions and produces `SKILL.md` updates. Which skills would benefit? The `next-task` skill (selected via `next-task-context` skill at `.devin/skills/`) is a natural candidate — a long-running marathon produces hundreds of `next-task` invocations, each with different success/failure signals. The `grind-log-analyze` skill itself is a candidate: every post-mortem teaches what to look for next time. Lower-priority candidates: anything that's repo-specific (the audit cascade skills).
    4. **Composability with existing post-mortem**: `grind-log-analyze` already produces tasks from a log. SkillClaw would produce skill edits from the same log. **They are complementary, not redundant** — tasks live in `TASKS.md`, evolved skills live in `~/.skillclaw/skills/` (or `~/.claude/skills/`, depending on the integration). Confirm no overlap by running both on the same log and diffing the outputs.
    5. **Taskgrind's role in the integration** — minimal: emit the trace, let SkillClaw consume it. Don't add a SkillClaw client to taskgrind itself. Don't add evolve-server orchestration to taskgrind. The user installs SkillClaw separately (via the [`catalog-add-skillclaw` task](../agentbrew/TASKS.md) in agentbrew, when that lands), points its `sharing.local_root` at taskgrind's session log directory, and runs `skillclaw-evolve-server` themselves.
    **What's explicitly out of scope**:
    - Adding a SkillClaw daemon or client process to taskgrind itself — taskgrind stays a self-contained shell tool.
    - Implementing the evolve loop in taskgrind — that's SkillClaw's job.
    - Multi-user / OSS / S3 storage — single-user / local-only is the only mode worth researching here.
    - Replacing `grind-log-analyze` — the two are complementary; don't merge them.
    **Cheap, falsifiable dev-machine checks** (≤1 day, budget-bounded):
    1. Install SkillClaw locally per the README (`bash scripts/install_skillclaw.sh`). Verify `skillclaw setup` completes and `skillclaw start --daemon` runs. Check that `skillclaw-evolve-server --use-skillclaw-config --interval 300 --port 8787` consumes a synthetic session.
    2. Hand-craft one `session_trace.jsonl` from a recent taskgrind log (use a real `taskgrind-<date>-<repo>-*.log` from `$TMPDIR`). Drop it into `~/.skillclaw/local-share/<group_id>/sessions/`. Confirm the evolve server picks it up and produces a sane `SKILL.md` candidate.
    3. Time-box the format mapping per backend at ≤30 minutes. If devin's structured log can't be mapped to SkillClaw's format in 30 minutes, the gap is too wide for that backend; record it.
    **Outcome — three possible verdicts** documented in `docs/research/skillclaw-export.md` (new):
    - **(a) Implement minimal exporter**: a `bin/taskgrind-export-trace` helper script reads the latest log and emits the SkillClaw trace format. Add `TG_EMIT_SKILLCLAW_TRACE=1` env opt-in for users who run a SkillClaw evolve server alongside. Keep the surface area tiny — one script, one opt-in.
    - **(b) Document the integration without code**: write a `docs/skillclaw-integration.md` that explains how a user can run SkillClaw alongside taskgrind by pointing it at the existing log directory + a small awk/python parser they can copy-paste. No taskgrind changes. Cheapest option if SkillClaw matures and a community parser emerges.
    - **(c) Reject + record**: format gap too wide, or SkillClaw too young (1k stars, first OSS release April 2026) to build against today. File for ≥90-day re-evaluation; document the blocker.
    **Why P2, not P1**: this is "extends capability for users who have already adopted SkillClaw." It doesn't fix any taskgrind bug or unblock any current marathon. The two P0 / P1 tasks already in this file (the attempt-counter fix and the diminishing-returns default) are far higher value for current users.
    **Anti-pattern to avoid**: don't pre-build the exporter before the spike concludes. The format SkillClaw expects may shift in the next 90 days (very young project), and a half-built exporter against a moving target is worse than nothing. Spike first; build only after the verdict.
  - **Files**: `bin/taskgrind` (read-only during spike — for log-format inspection), `.devin/skills/grind-log-analyze/SKILL.md` (read-only during spike — for composability check), `docs/research/skillclaw-export.md` (new, ~1-page decision doc), optionally `bin/taskgrind-export-trace` (new — only if verdict is "implement"), `docs/skillclaw-integration.md` (new — only if verdict is "document")
  - **Acceptance**: `docs/research/skillclaw-export.md` exists with one of the three verdicts and one paragraph each on the five concrete checks above; the format-gap question is answered per-backend (devin / claude-code / codex) with a concrete time estimate for each adapter; one head-to-head test runs both `grind-log-analyze` and a hand-crafted SkillClaw trace on the same real taskgrind log and confirms outputs are complementary, not duplicate; if verdict is "implement", the new env opt-in `TG_EMIT_SKILLCLAW_TRACE=1` is documented in `README.md` and `man/taskgrind.1` per AGENTS.md rules 3 + 7; if verdict is "reject", the blocker is recorded so this task isn't picked up again for 90 days; `make check` passes regardless of verdict (the spike doc itself doesn't change runtime behavior)


