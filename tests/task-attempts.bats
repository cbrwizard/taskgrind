#!/usr/bin/env bats

load test_helper

DVB_GRIND="$BATS_TEST_DIRNAME/../bin/taskgrind"

@test "attempt write failures are logged and later sessions still reach skip threshold" {
  local real_mv shim_dir state_file

  cat > "$TEST_REPO/TASKS.md" <<'TASKS'
# Tasks
## P0
- [ ] Persistent test task
  **ID**: persistent-test-task
TASKS

  real_mv="$(command -v mv)"
  shim_dir="$TEST_DIR/shims"
  state_file="$TEST_DIR/mv-state"
  mkdir -p "$shim_dir"

  cat > "$shim_dir/mv" <<SCRIPT
#!/bin/bash
if [[ "\$1" == *taskgrind-att-*.new && "\$2" == *taskgrind-att-* && ! -f "$state_file" ]]; then
  : > "$state_file"
  echo "simulated mv failure" >&2
  exit 1
fi
exec "$real_mv" "\$@"
SCRIPT
  chmod +x "$shim_dir/mv"

  export PATH="$shim_dir:$PATH"
  export DVB_DEADLINE=$(( $(date +%s) + 15 ))
  export DVB_MAX_SESSION=1

  run "$DVB_GRIND" 4 "$TEST_REPO"
  [ "$status" -eq 0 ]

  grep -q 'attempt_write_failed:' "$TEST_LOG"
  grep -q 'task_skip_threshold ids=' "$TEST_LOG"
}
