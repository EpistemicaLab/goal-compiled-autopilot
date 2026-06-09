#!/usr/bin/env bash
# a3_audit.sh — static A3 (decomposition coverage) check.
#
# Usage: a3_audit.sh <state.json path> <goal text>
# Exit 0 = pass, 1 = FAIL (reason on stderr), no warn level.
#
# Catches the failure mode where the compiled FSM's gates do not cover
# the goal's stated success criterion. Three deterministic checks:
#   (a) filename coverage : every *.py the goal text mentions must appear
#       verbatim in some gate or in the DOD;
#   (b) test coverage     : if the goal mentions "test_*", "unittest", or
#       "pytest", at least one gate or DOD must reference a test;
#   (c) rejection coverage: if the goal mentions "raises ValueError",
#       "reject", or "safe", at least one gate or DOD must mention
#       raises/reject/safe/ValueError/assert.
#
# These three families cover every A3 plan-defect we observed in the
# weak-model bench (agi-nova-beta-1m × {hello-cli, safe-eval-arith,
# url-dedup}, all filename-hallucination + dropped requirements).
set -uo pipefail
state="${1:?usage: a3_audit.sh <state.json> <goal>}"
goal="${2:?usage: a3_audit.sh <state.json> <goal>}"

[ -f "$state" ] || { echo "A3_AUDIT_FAIL state-not-found: $state" >&2; exit 1; }

# Aggregate: DOD + every state's gate command + every state's desc
fsm_text="$(jq -r '
  (.dod // "")
  + " "
  + ([.states[].gate // ""] | join(" "))
  + " "
  + ([.states[].desc // ""] | join(" "))
' "$state")"

fail=0

# (a) filename coverage
for f in $(echo "$goal" | grep -oE '\b[a-z_][a-z_0-9]*\.py\b' | sort -u); do
  if ! grep -qF "$f" <<<"$fsm_text"; then
    echo "A3_AUDIT_FAIL filename-missing: goal mentions '$f' but no FSM gate/DOD references it" >&2
    fail=1
  fi
done

# (b) test coverage
if echo "$goal" | grep -qiE '\btest_|\bunittest\b|\bpytest\b'; then
  if ! grep -qiE 'test_|unittest|pytest' <<<"$fsm_text"; then
    echo "A3_AUDIT_FAIL test-missing: goal asks for tests; no FSM gate/DOD mentions test_/unittest/pytest" >&2
    fail=1
  fi
fi

# (c) rejection / security coverage
if echo "$goal" | grep -qiE '\b(raises|reject|escape|attack|safe[_\s])\b'; then
  if ! grep -qiE 'raises|reject|escape|valueerror|safe_|safe[a-z_]*\(|assert' <<<"$fsm_text"; then
    echo "A3_AUDIT_FAIL rejection-missing: goal asks for raises/reject/safe; no FSM gate/DOD references it" >&2
    fail=1
  fi
fi

exit $fail
