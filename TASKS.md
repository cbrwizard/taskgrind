# Tasks

## P3

- [ ] Error messages for common failures include actionable next-step guidance
  **ID**: test-error-message-quality
  **Tags**: tests, error-messages, ux
  **Details**: Several taskgrind error paths surface a reason but not a remediation. Examples: `Error: --model requires a name` (line 161) doesn't show a valid model; `Backend binary not found (devin)` (line 664) doesn't point at install docs. Most users see these once and bounce. Raise the floor by covering 5+ error paths with tests that assert each message mentions (a) what went wrong, (b) what to do next, (c) a doc link or example where relevant. The test itself becomes the spec for "a good error message" in this repo.
  **Files**: `tests/diagnostics.bats`, `bin/taskgrind`
  **Acceptance**: At least five error paths (missing backend, invalid model, invalid numeric env var, missing repo path, unsupported backend) have tests asserting the error includes both the cause and an actionable next step. Any new error path added after this task is expected to pass the same pattern.
