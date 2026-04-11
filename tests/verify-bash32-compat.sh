#!/bin/bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
scratch_dir="$(mktemp -d)"
trap 'rm -rf "$scratch_dir"' EXIT

test_repo="$scratch_dir/repo"
mkdir -p "$test_repo"
cat > "$test_repo/TASKS.md" <<'TASKS'
# Tasks
## P0
- [ ] Bash compatibility smoke test
TASKS

check_disallowed_bash4_syntax() {
  local runtime_file
  for runtime_file in \
    "$repo_root/bin/taskgrind" \
    "$repo_root/lib/constants.sh" \
    "$repo_root/lib/fullpower.sh"; do
    if grep -nE \
      '(^|[[:space:]])(declare|local|typeset)[[:space:]]+-A([[:space:]=]|$)|(^|[[:space:]])(mapfile|readarray|coproc)([[:space:];]|$)|\$\{[^}]*(\^\^|,,|@[QEPAKakUuL])' \
      "$runtime_file"; then
      echo "Bash 3.2 compatibility check failed for $runtime_file" >&2
      exit 1
    fi
  done
}

check_disallowed_bash4_syntax

DVB_GRIND_CMD=/bin/true \
DVB_SKIP_PREFLIGHT=1 \
DVB_SKIP_SWEEP_ON_EMPTY=1 \
/bin/bash "$repo_root/bin/taskgrind" --dry-run "$test_repo" 1 >/dev/null
