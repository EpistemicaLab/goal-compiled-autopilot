#!/usr/bin/env bash
# Held-out oracle for sympy__sympy-20049: apply test_patch, run pytest, return PASS/FAIL.
set -uo pipefail
WORKDIR="${1:?work dir required}"
TASK_DIR="$(dirname "$(realpath "$0")")"
cd "$WORKDIR"
# Apply held-out test patch (the test the gold solution must pass)
git apply --whitespace=nowarn "$TASK_DIR/test.patch" 2>&1 | tail -3 || true
# Run pytest; SWE-bench tests are typically isolated to a few files
if pytest -x --tb=short 2>&1 | tail -15 | tee /tmp/oracle_out_sympy__sympy-20049.log; then
  if grep -qE "passed" /tmp/oracle_out_sympy__sympy-20049.log; then
    echo PASS
    exit 0
  fi
fi
echo FAIL
exit 1
