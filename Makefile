.PHONY: lint test test-all check

lint:
	@echo "═══ Shellcheck ═══"
	@cd bin && shellcheck -x taskgrind && cd ../lib && shellcheck constants.sh fullpower.sh && echo "✓ All scripts pass shellcheck"

test:
	@echo "═══ Tests ═══"
	@bats tests/taskgrind.bats

test-all: test

check: lint test
