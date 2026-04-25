# Tasks

## P2

- [ ] `slot_lock_pid()` and `slot_lock_active()` have direct unit-style test coverage
  **ID**: test-slot-lock-helpers
  **Tags**: tests, multi-instance, locking
  **Details**: `slot_lock_pid()` (`bin/taskgrind:641`) and `slot_lock_active()` (`bin/taskgrind:647`) are the probe helpers that `--preflight` uses to report `slots: N/M active` and that the multi-instance path uses to detect stale locks. They are tested only through the full concurrent grind flows in `tests/multi-instance.bats`. A regression that always returned "lock not active" would silently break the "all slots full" refusal and pass the higher-level tests. Add direct coverage: write a fake lock file with a live pid (the bats runner itself) vs a dead pid (a recycled pid that no longer exists) and assert the return code / printed pid.
  **Files**: `tests/multi-instance.bats`
  **Acceptance**: (1) A test proves `slot_lock_pid` prints the pid from a valid lock file and returns 1 on a missing/empty file. (2) A test proves `slot_lock_active` returns 0 for a live pid and 1 for a clearly-dead pid (use a fixture pid that is guaranteed not to exist, e.g. the highest unused value on Linux/macOS). (3) Tests source the functions via `awk` extract, matching the existing pattern.

## P3

- [ ] Repo ships a `.editorconfig` so contributors get consistent indentation in shell, bats, and markdown files
  **ID**: add-editorconfig
  **Tags**: dx, style, onboarding
  **Details**: The taskgrind tree mixes `bin/` bash (2-space indent), `tests/*.bats` (2-space indent), `lib/*.sh` (2-space indent), and markdown. Contributors using editors that honor `.editorconfig` (VS Code, JetBrains, Vim plugins) would set indentation correctly on first open. Today there is none. Both the `dotfiles` and `tasks.md` sibling repos ship one. Add `.editorconfig` with one entry per file type and document it in `CONTRIBUTING.md`.
  **Files**: `.editorconfig`, `CONTRIBUTING.md`
  **Acceptance**: A new `.editorconfig` covers `*.{sh,bash,bats}` (2-space indent, LF line endings, final newline), `*.md` (preserve trailing spaces for hard breaks, LF line endings, final newline), and `Makefile` (tab indentation, 8-char width). `CONTRIBUTING.md` mentions it in the Quick Start or Project Structure section. `make check` still passes.


