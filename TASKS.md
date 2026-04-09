# Tasks

## P0

## P1

## P2

- [ ] Rename DVB_ env vars to TG_ with backward compat aliases
  **ID**: rename-env-vars
  **Tags**: api, breaking-change
  **Details**: All env vars use the `DVB_` prefix (from the original `dvb-grind` name). Now that the tool is `taskgrind`, the canonical prefix should be `TG_` (e.g. `TG_MODEL`, `TG_SKILL`). Keep `DVB_` as fallback aliases: `model="${TG_MODEL:-${DVB_MODEL:-$DEFAULT_MODEL}}"`. Update --help, README, AGENTS.md. This is a low-priority cosmetic change — DVB_ works fine.
  **Files**: bin/taskgrind, lib/constants.sh, README.md, AGENTS.md
  **Acceptance**: `TG_MODEL=sonnet taskgrind --dry-run` works; `DVB_MODEL=sonnet taskgrind --dry-run` still works; --help shows TG_ as primary

## P3

- [ ] Linux portability: replace macOS-only commands
  **ID**: linux-portability
  **Tags**: portability
  **Details**: Several commands are macOS-only: `caffeinate` (sleep prevention), `lockf` (file locking), `osascript` (notifications), `stat -f %m` (file mtime). Add Linux fallbacks: `systemd-inhibit` or no-op for caffeinate, `flock` for lockf, `notify-send` for osascript, `stat -c %Y` for mtime. Guard with `[[ "$(uname)" == "Darwin" ]]` checks.
  **Files**: bin/taskgrind
  **Acceptance**: `taskgrind --preflight` passes on Ubuntu; full grind loop works on Linux

- [ ] Add man page
  **ID**: add-man-page
  **Tags**: docs, distribution
  **Details**: Generate a man page from --help output or write `taskgrind.1` manually. Install to standard man path. Low priority — --help is sufficient for most users.
  **Files**: man/taskgrind.1
  **Acceptance**: `man taskgrind` works after install

- [ ] Homebrew tap for easy install
  **ID**: homebrew-tap
  **Tags**: distribution
  **Details**: Create a Homebrew tap (`cbrwizard/tap`) with a formula for taskgrind. Formula clones the repo and symlinks `bin/taskgrind` to the Homebrew prefix. Depends on `bats-core` (test) and `shellcheck` (dev).
  **Files**: separate repo (homebrew-tap), README.md (update install section)
  **Acceptance**: `brew install cbrwizard/tap/taskgrind` installs and `taskgrind --help` works
