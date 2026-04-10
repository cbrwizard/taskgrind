# Tasks

## P0

## P1

## P2

- [ ] Sweep sessions bypass network-wait and fast-failure recovery
  **ID**: sweep-network-recovery
  **Tags**: stability, network
  **Details**: The empty-queue sweep path (tasks_before=0) runs a backend session and then `continue`s to the top of the while loop, skipping the fast-failure detection and wait_for_network logic at lines 1053-1094. A transient network drop during a sweep permanently ends the marathon instead of pausing and retrying. Add fast-failure/network-wait handling after sweep sessions, same as regular sessions.
  **Files**: bin/taskgrind, tests/taskgrind.bats
  **Acceptance**: Sweep session that crashes in <min_session_secs triggers network check and wait_for_network, same as regular sessions. New test covers this path.

## P3

- [ ] Homebrew tap for easy install
  **ID**: homebrew-tap
  **Tags**: distribution
  **Details**: Create a Homebrew tap (`cbrwizard/tap`) with a formula for taskgrind. Formula clones the repo and symlinks `bin/taskgrind` to the Homebrew prefix. Depends on `bats-core` (test) and `shellcheck` (dev).
  **Files**: separate repo (homebrew-tap), README.md (update install section)
  **Acceptance**: `brew install cbrwizard/tap/taskgrind` installs and `taskgrind --help` works
