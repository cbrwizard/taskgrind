# User Stories

Real usage patterns for taskgrind. Each story shows the context, command, what happens, and sample log output.

## 1. Overnight grind on a repo with tasks

You have a repo with a `TASKS.md` full of work items. You want to leave the machine grinding overnight and come back to shipped tasks in the morning.

```bash
taskgrind ~/apps/myproject 8
```

What happens:
- Taskgrind launches AI sessions in a loop, each picking the highest-priority task from `TASKS.md`
- Each session implements a task, commits, removes it from `TASKS.md`, and exits
- Between sessions: 5s cooldown, git sync every 5 sessions
- After 8 hours (or when the queue empties), taskgrind exits with a summary

Sample log:
```
[09:00] session_start session=1 remaining=480m tasks=12
[09:45] session_end session=1 exit=0 duration=2700s shipped=1 tasks_after=11
[09:45] session_start session=2 remaining=435m tasks=11
...
[17:00] grind_done sessions=10 shipped=8 remaining_tasks=4 rate=0.80 elapsed=28800s
```

## 2. Focused grind with --prompt

You want sessions to prioritize a specific area (e.g., test coverage) but still pick up other tasks if nothing matches.

```bash
taskgrind --prompt "focus on test coverage" ~/apps/myproject 4
```

What happens:
- Every session prompt includes priority framing: pick tasks matching the focus first, then fall back to unrelated tasks
- The focus shows in the startup banner and log header
- Useful for targeting a specific improvement area across many sessions

Sample banner:
```
   taskgrind: 4.0h, opus, devin
   repo:  ~/apps/myproject (12 tasks)
   focus: focus on test coverage
   log:   /tmp/taskgrind-myproject-12345.log
```

## 3. Multi-repo grind

You have tasks spread across two repos. Run one grind per repo, either sequentially or in separate terminals.

```bash
# Terminal 1
taskgrind ~/apps/frontend 6

# Terminal 2
taskgrind ~/apps/backend 6
```

What happens:
- Each instance locks its repo (via `lockf`) so two grinds can't run on the same repo
- Each gets its own log file (includes repo name + PID)
- Both use caffeinate to prevent system sleep

## 4. Fleet-grind for pipeline management

You're managing an orchestrator that runs multiple AI pipelines. Use the `fleet-grind` skill to monitor and fix pipelines instead of picking tasks.

```bash
taskgrind --skill fleet-grind ~/apps/bosun 10
```

What happens:
- Each session runs the `fleet-grind` skill instead of `next-task`
- The skill monitors pipelines, fixes failures, merges PRs
- Sessions may be longer (productive timeouts auto-increase the timeout cap)

## 5. Dry-run / preflight to check before committing

Before starting an 8-hour grind, verify everything is set up correctly.

```bash
# Check config without running
taskgrind --dry-run 8 ~/apps/myproject

# Run health checks
taskgrind --preflight ~/apps/myproject
```

Dry-run output:
```
   taskgrind: 8.0h, opus, devin
   repo:  ~/apps/myproject
   skill: next-task
   early_exit_on_stall: enabled
```

Preflight output:
```
   ── Preflight ──────────────────────────────
   taskgrind: 8.0h, opus, devin
   repo:  ~/apps/myproject

   [PASS] devin binary found
   [PASS] network connectivity
   [PASS] git repo clean
   [PASS] git remote configured
   [PASS] disk space sufficient
   [PASS] TASKS.md found (12 tasks)
   [PASS] network-watchdog available

   ── Summary: 7 pass, 0 warn, 0 fail ───────
```
